import Foundation
import SwiftData

struct LearningPlanSnapshot: Equatable, Sendable {
    let solvedIDs: Set<String>
    let nextProblemID: String?
    let nextMLProblemID: String?
    let accessibleIDs: Set<String>
    let dueReviewIDs: [String]
    let flaggedReviewIDs: [String]

    var solvedCount: Int { solvedIDs.count }
}

enum LearningMilestone: Equatable, Sendable {
    case attemptRecorded
    case firstSolve
    case reviewCompleted(level: Int)
}

enum LearningProgressServiceError: LocalizedError, Equatable {
    case problemMismatch

    var errorDescription: String? {
        "CodeStreak stopped a draft from being saved to the wrong problem. Reopen the problem and try again."
    }
}

struct LearningPlanEngine {
    private static let knownProblemIDs = Set(Curriculum.allProblems.map(\.id))

    func snapshot(records: [LearningProgressRecord], now: Date = .now) -> LearningPlanSnapshot {
        // A newer app can sync curriculum records that an older build does not
        // know yet. Keep those records in SwiftData, but do not let them inflate
        // this build's solved total or appear as impossible review missions.
        let knownRecords = records.filter { Self.knownProblemIDs.contains($0.problemID) }
        let solved = Set(knownRecords.filter(\.isSolved).map(\.problemID))
        var accessible = solved
        let algorithmProgression = progression(through: Curriculum.modules, solvedIDs: solved)
        let mlProgression = progression(through: Curriculum.mlInterviewModules, solvedIDs: solved)
        accessible.formUnion(algorithmProgression.accessibleProblemIDs)
        accessible.formUnion(mlProgression.accessibleProblemIDs)

        let due = knownRecords
            .filter {
                ($0.isSolved && ($0.nextReviewAt ?? .distantFuture) <= now)
                    || ($0.isFlaggedForReview && ($0.flaggedReviewAt ?? .distantFuture) <= now)
            }
            .sorted { reviewDate(for: $0) < reviewDate(for: $1) }
            .map(\.problemID)
        let flaggedDue = knownRecords
            .filter { $0.isFlaggedForReview && ($0.flaggedReviewAt ?? .distantFuture) <= now }
            .sorted { ($0.flaggedReviewAt ?? .distantPast) < ($1.flaggedReviewAt ?? .distantPast) }
            .map(\.problemID)

        return LearningPlanSnapshot(
            solvedIDs: solved,
            nextProblemID: algorithmProgression.recommendedProblemID,
            nextMLProblemID: mlProgression.recommendedProblemID,
            accessibleIDs: accessible,
            dueReviewIDs: due,
            flaggedReviewIDs: flaggedDue
        )
    }

    /// Every problem in the first incomplete module is available. A later
    /// module contributes no accessible problems until every problem in each
    /// earlier module has been solved.
    private func progression(
        through modules: [CurriculumModule],
        solvedIDs: Set<String>
    ) -> (recommendedProblemID: String?, accessibleProblemIDs: Set<String>) {
        guard let activeModule = modules.first(where: { module in
            module.problems.contains { !solvedIDs.contains($0.id) }
        }) else {
            return (nil, [])
        }

        let recommended = activeModule.problems.first { !solvedIDs.contains($0.id) }?.id
        return (recommended, Set(activeModule.problems.map(\.id)))
    }

    private func reviewDate(for record: LearningProgressRecord) -> Date {
        min(
            record.isSolved ? record.nextReviewAt ?? .distantFuture : .distantFuture,
            record.isFlaggedForReview ? record.flaggedReviewAt ?? .distantFuture : .distantFuture
        )
    }
}

@MainActor
struct LearningProgressService {
    private let reviewIntervalsInDays = [1, 3, 7, 14, 30, 60]
    private let flaggedReviewIntervalsInDays = [3, 7, 14, 30]

    func record(
        for problem: AlgorithmProblem,
        context: ModelContext
    ) throws -> LearningProgressRecord {
        let problemID = problem.id
        var descriptor = FetchDescriptor<LearningProgressRecord>(
            predicate: #Predicate { $0.problemID == problemID }
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            if existing.draftCode.isEmpty {
                existing.draftCode = problem.starterCode
                touch(existing)
                try saveOrRollback(context)
            }
            return existing
        }

        let record = LearningProgressRecord(
            problemID: problem.id,
            draftCode: problem.starterCode,
            modifiedBy: DeviceIdentity.id
        )
        context.insert(record)
        try saveOrRollback(context)
        return record
    }

    func saveDraft(
        _ record: LearningProgressRecord,
        forProblemID problemID: String,
        code: String,
        notes: String,
        scratchpadCode: String? = nil,
        context: ModelContext
    ) throws {
        guard record.problemID == problemID else {
            throw LearningProgressServiceError.problemMismatch
        }
        let requestedScratchpad = scratchpadCode ?? record.scratchpadCode
        // The visible starter cell is a placeholder, not user work. Store it as
        // empty so merely opening and closing a problem does not create a sync
        // edit. Resetting a previously edited cell still changes it to empty.
        let updatedScratchpad = requestedScratchpad == PythonScratchpad.starterCode
            ? ""
            : requestedScratchpad
        let hasScratchWork = !updatedScratchpad.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && updatedScratchpad != PythonScratchpad.starterCode
        let shouldMarkInProgress = record.status == .notStarted && (
            code != Curriculum.problem(withID: record.problemID)?.starterCode
                || !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || hasScratchWork
        )
        let contentChanged = record.draftCode != code
            || record.notes != notes
            || record.scratchpadCode != updatedScratchpad

        // Workspace disappearance and test runs both flush pending edits. If
        // nothing changed, touching modifiedAt would make an old device look
        // newer and allow its stale whole-record sync copy to win.
        guard contentChanged || shouldMarkInProgress else { return }

        record.draftCode = code
        record.notes = notes
        record.scratchpadCode = updatedScratchpad
        if shouldMarkInProgress {
            record.status = .inProgress
        }
        touch(record)
        try saveOrRollback(context)
    }

    func addStudyTime(
        _ record: LearningProgressRecord,
        seconds: Int,
        at date: Date = .now,
        context: ModelContext
    ) throws {
        guard seconds > 0 else { return }
        let current = max(record.timeSpentSeconds, 0)
        let (total, overflowed) = current.addingReportingOverflow(seconds)
        record.timeSpentSeconds = overflowed ? Int.max : total
        if record.status == .notStarted { record.status = .inProgress }
        touch(record, at: date)
        try saveOrRollback(context)
    }

    func resetStudyTime(
        _ record: LearningProgressRecord,
        at date: Date = .now,
        context: ModelContext
    ) throws {
        guard record.timeSpentSeconds != 0 else { return }
        record.timeSpentSeconds = 0
        touch(record, at: date)
        try saveOrRollback(context)
    }

    func revealNextHint(_ record: LearningProgressRecord, maximum: Int, context: ModelContext) throws {
        let limit = max(maximum, 0)
        let currentCount = min(max(record.hintsRevealed, 0), limit)
        let nextCount = currentCount < limit ? currentCount + 1 : currentCount
        let shouldMarkInProgress = record.status == .notStarted && limit > 0
        guard nextCount != record.hintsRevealed || shouldMarkInProgress else { return }
        record.hintsRevealed = nextCount
        if shouldMarkInProgress { record.status = .inProgress }
        touch(record)
        try saveOrRollback(context)
    }

    func markReferenceViewed(_ record: LearningProgressRecord, context: ModelContext) throws {
        guard !record.referenceViewed else { return }
        record.referenceViewed = true
        if record.status == .notStarted { record.status = .inProgress }
        touch(record)
        try saveOrRollback(context)
    }

    @discardableResult
    func flagForReview(
        _ record: LearningProgressRecord,
        at date: Date = .now,
        calendar: Calendar = .autoupdatingCurrent,
        context: ModelContext
    ) throws -> Date {
        if record.isFlaggedForReview, let existingDate = record.flaggedReviewAt {
            return existingDate
        }
        record.isFlaggedForReview = true
        record.flaggedReviewLevel = 0
        record.flaggedReviewAt = flaggedReviewDate(after: date, level: 0, calendar: calendar)
        if record.status == .notStarted { record.status = .inProgress }
        touch(record, at: date)
        try saveOrRollback(context)
        WidgetProgressExporter.refresh(context: context, now: date)
        return record.flaggedReviewAt ?? date
    }

    func clearReviewFlag(
        _ record: LearningProgressRecord,
        at date: Date = .now,
        context: ModelContext
    ) throws {
        guard record.isFlaggedForReview || record.flaggedReviewAt != nil else { return }
        record.isFlaggedForReview = false
        record.flaggedReviewAt = nil
        record.flaggedReviewLevel = 0
        touch(record, at: date)
        try saveOrRollback(context)
        WidgetProgressExporter.refresh(context: context, now: date)
    }

    @discardableResult
    func completeFlaggedReview(
        _ record: LearningProgressRecord,
        at date: Date = .now,
        calendar: Calendar = .autoupdatingCurrent,
        context: ModelContext
    ) throws -> Date? {
        guard record.isFlaggedForReview else { return nil }
        let currentLevel = min(
            max(record.flaggedReviewLevel, 0),
            flaggedReviewIntervalsInDays.count - 1
        )
        record.flaggedReviewLevel = min(
            currentLevel + 1,
            flaggedReviewIntervalsInDays.count - 1
        )
        record.flaggedReviewAt = flaggedReviewDate(
            after: date,
            level: record.flaggedReviewLevel,
            calendar: calendar
        )
        touch(record, at: date)
        try saveOrRollback(context)
        WidgetProgressExporter.refresh(context: context, now: date)
        return record.flaggedReviewAt
    }

    func recordRun(
        _ record: LearningProgressRecord,
        passed: Bool,
        at date: Date = .now,
        calendar: Calendar = .autoupdatingCurrent,
        context: ModelContext
    ) throws -> LearningMilestone {
        let wasSolved = record.isSolved
        let reviewWasDue = wasSolved && (record.nextReviewAt ?? .distantFuture) <= date
        let currentAttempts = max(record.attemptCount, 0)
        record.attemptCount = currentAttempts == Int.max ? Int.max : currentAttempts + 1
        record.lastAttemptAt = date

        var milestone = LearningMilestone.attemptRecorded
        if passed {
            record.status = .solved
            if !wasSolved {
                record.solvedAt = date
                record.reviewLevel = 0
                record.nextReviewAt = reviewDate(after: date, level: 0, calendar: calendar)
                milestone = .firstSolve
            } else if reviewWasDue {
                let currentLevel = min(max(record.reviewLevel, 0), reviewIntervalsInDays.count - 1)
                record.reviewLevel = min(currentLevel + 1, reviewIntervalsInDays.count - 1)
                record.nextReviewAt = reviewDate(after: date, level: record.reviewLevel, calendar: calendar)
                milestone = .reviewCompleted(level: record.reviewLevel)
            }
        } else if !wasSolved {
            record.status = .inProgress
        }

        touch(record, at: date)
        try saveOrRollback(context)
        WidgetProgressExporter.refresh(context: context, now: date)
        return milestone
    }

    private func reviewDate(after date: Date, level: Int, calendar: Calendar) -> Date {
        let index = min(max(level, 0), reviewIntervalsInDays.count - 1)
        return calendar.date(byAdding: .day, value: reviewIntervalsInDays[index], to: date) ?? date
    }

    private func flaggedReviewDate(after date: Date, level: Int, calendar: Calendar) -> Date {
        let index = min(max(level, 0), flaggedReviewIntervalsInDays.count - 1)
        return calendar.date(
            byAdding: .day,
            value: flaggedReviewIntervalsInDays[index],
            to: date
        ) ?? date
    }

    private func touch(_ record: LearningProgressRecord, at date: Date = .now) {
        record.modifiedAt = date
        record.modifiedBy = DeviceIdentity.id
    }

    private func saveOrRollback(_ context: ModelContext) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

/// Collapses progress created by the former eight-label mastery generator into
/// the one real problem that now represents each design. Legacy records remain
/// stored for compatibility with an older paired build, but the learning plan
/// ignores them and this merge is deliberately idempotent.
@MainActor
struct CurriculumProgressMigrationService {
    private let legacyFocusNames = [
        "Foundation", "Boundary cases", "Pattern recall", "Speed round",
        "Transfer practice", "Interview mode", "Spaced review", "Mastery check"
    ]

    @discardableResult
    func migrate(context: ModelContext, at date: Date = .now) throws -> Int {
        let records = try context.fetch(FetchDescriptor<LearningProgressRecord>())
        var currentByID = Dictionary(uniqueKeysWithValues: records.map { ($0.problemID, $0) })
        let groupedLegacy = Dictionary(grouping: records.compactMap { record -> LegacyRecord? in
            guard let info = legacyInfo(for: record.problemID) else { return nil }
            return LegacyRecord(record: record, canonicalID: info.canonicalID, focus: info.focus)
        }, by: \.canonicalID)
        var changedCount = 0

        for (canonicalID, legacyRecords) in groupedLegacy {
            guard let problem = Curriculum.problem(withID: canonicalID) else { continue }
            let target: LearningProgressRecord
            let inserted: Bool
            if let existing = currentByID[canonicalID] {
                target = existing
                inserted = false
            } else {
                target = LearningProgressRecord(
                    problemID: canonicalID,
                    draftCode: problem.starterCode,
                    modifiedAt: .distantPast,
                    modifiedBy: DeviceIdentity.id
                )
                context.insert(target)
                currentByID[canonicalID] = target
                inserted = true
            }

            let sources = [MigrationSource(record: target, label: "canonical problem", legacyNumber: nil)]
                + legacyRecords.map {
                    MigrationSource(
                        record: $0.record,
                        label: $0.focus,
                        legacyNumber: legacyNumber(for: $0.record.problemID)
                    )
                }
            let values = mergedValues(from: sources, target: target, problem: problem)
            let changed = inserted || !values.matches(target)
            guard changed else { continue }

            target.status = values.status
            target.draftCode = values.draftCode
            target.notes = values.notes
            target.scratchpadCode = values.scratchpadCode
            target.attemptCount = values.attemptCount
            target.hintsRevealed = values.hintsRevealed
            target.referenceViewed = values.referenceViewed
            target.timeSpentSeconds = values.timeSpentSeconds
            target.solvedAt = values.solvedAt
            target.lastAttemptAt = values.lastAttemptAt
            target.nextReviewAt = values.nextReviewAt
            target.reviewLevel = values.reviewLevel
            target.isFlaggedForReview = values.isFlaggedForReview
            target.flaggedReviewAt = values.flaggedReviewAt
            target.flaggedReviewLevel = values.flaggedReviewLevel
            let latestSourceEdit = sources.map(\.record.modifiedAt).max() ?? .distantPast
            target.modifiedAt = max(date, latestSourceEdit.addingTimeInterval(0.001))
            target.modifiedBy = DeviceIdentity.id
            changedCount += 1
        }

        guard changedCount > 0 else { return 0 }
        do {
            try context.save()
            WidgetProgressExporter.refresh(context: context, now: date)
            return changedCount
        } catch {
            context.rollback()
            throw error
        }
    }

    private func mergedValues(
        from sources: [MigrationSource],
        target: LearningProgressRecord,
        problem: AlgorithmProblem
    ) -> MigratedValues {
        let normalizedDrafts = sources.compactMap { source -> MigratedText? in
            let code = normalize(source.record.draftCode, from: source, to: problem)
            guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  code != problem.starterCode else { return nil }
            return MigratedText(text: code, source: source)
        }
        let chosenDraft = normalizedDrafts.max { lhs, rhs in
            lhs.source.record.modifiedAt < rhs.source.record.modifiedAt
        }

        var notes = target.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        for source in sources where source.record !== target {
            let sourceNotes = source.record.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            if !sourceNotes.isEmpty {
                appendPreserved(
                    "Migrated note from \(source.label)",
                    text: sourceNotes,
                    to: &notes
                )
            }
        }
        for draft in normalizedDrafts where draft.text != chosenDraft?.text {
            appendPreserved(
                "Earlier solution from \(draft.source.label)",
                text: draft.text,
                to: &notes
            )
        }

        let scratchpads = sources.compactMap { source -> MigratedText? in
            let code = normalize(source.record.scratchpadCode, from: source, to: problem)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !code.isEmpty, code != PythonScratchpad.starterCode else { return nil }
            return MigratedText(text: code, source: source)
        }
        let chosenScratchpad = scratchpads.max { lhs, rhs in
            lhs.source.record.modifiedAt < rhs.source.record.modifiedAt
        }
        for scratchpad in scratchpads where scratchpad.text != chosenScratchpad?.text {
            appendPreserved(
                "Earlier scratchpad from \(scratchpad.source.label)",
                text: scratchpad.text,
                to: &notes
            )
        }

        let solvedSources = sources.filter { $0.record.isSolved }
        let status: LearningStatus = if !solvedSources.isEmpty {
            .solved
        } else if sources.contains(where: { $0.record.status == .inProgress }) {
            .inProgress
        } else {
            .notStarted
        }
        let reviewLevel = solvedSources.map { max($0.record.reviewLevel, 0) }.max() ?? 0
        let nextReviewAt = solvedSources
            .filter { max($0.record.reviewLevel, 0) == reviewLevel }
            .compactMap(\.record.nextReviewAt)
            .min()
        let flaggedSources = sources.filter { $0.record.isFlaggedForReview }

        return MigratedValues(
            status: status,
            draftCode: chosenDraft?.text ?? problem.starterCode,
            notes: notes,
            scratchpadCode: chosenScratchpad?.text ?? "",
            attemptCount: sources.map { max($0.record.attemptCount, 0) }.max() ?? 0,
            hintsRevealed: sources.map { max($0.record.hintsRevealed, 0) }.max() ?? 0,
            referenceViewed: sources.contains { $0.record.referenceViewed },
            timeSpentSeconds: sources.map { max($0.record.timeSpentSeconds, 0) }.max() ?? 0,
            solvedAt: solvedSources.compactMap(\.record.solvedAt).min(),
            lastAttemptAt: sources.compactMap(\.record.lastAttemptAt).max(),
            nextReviewAt: nextReviewAt,
            reviewLevel: reviewLevel,
            isFlaggedForReview: !flaggedSources.isEmpty,
            flaggedReviewAt: flaggedSources.compactMap(\.record.flaggedReviewAt).min(),
            flaggedReviewLevel: flaggedSources.map { max($0.record.flaggedReviewLevel, 0) }.max() ?? 0
        )
    }

    private func normalize(
        _ text: String,
        from source: MigrationSource,
        to problem: AlgorithmProblem
    ) -> String {
        guard let number = source.legacyNumber else { return text }
        let legacyFunctionName = "\(problem.functionName)_practice_\(number)"
        return text.replacingOccurrences(of: legacyFunctionName, with: problem.functionName)
    }

    private func appendPreserved(_ heading: String, text: String, to notes: inout String) {
        let block = "\(heading):\n\(text)"
        guard !notes.contains(block) else { return }
        if !notes.isEmpty { notes += "\n\n" }
        notes += block
    }

    private func legacyInfo(for problemID: String) -> (canonicalID: String, focus: String)? {
        let parts = problemID.split(separator: ".").map(String.init)
        guard parts.count == 4,
              parts[0] == "mastery",
              let number = Int(parts[3]),
              legacyFocusNames.indices.contains(number - 1) else { return nil }
        return (parts.dropLast().joined(separator: "."), legacyFocusNames[number - 1])
    }

    private func legacyNumber(for problemID: String) -> Int? {
        problemID.split(separator: ".").last.flatMap { Int($0) }
    }

    private struct LegacyRecord {
        let record: LearningProgressRecord
        let canonicalID: String
        let focus: String
    }

    private struct MigrationSource {
        let record: LearningProgressRecord
        let label: String
        let legacyNumber: Int?
    }

    private struct MigratedText {
        let text: String
        let source: MigrationSource
    }

    private struct MigratedValues {
        let status: LearningStatus
        let draftCode: String
        let notes: String
        let scratchpadCode: String
        let attemptCount: Int
        let hintsRevealed: Int
        let referenceViewed: Bool
        let timeSpentSeconds: Int
        let solvedAt: Date?
        let lastAttemptAt: Date?
        let nextReviewAt: Date?
        let reviewLevel: Int
        let isFlaggedForReview: Bool
        let flaggedReviewAt: Date?
        let flaggedReviewLevel: Int

        func matches(_ record: LearningProgressRecord) -> Bool {
            record.status == status
                && record.draftCode == draftCode
                && record.notes == notes
                && record.scratchpadCode == scratchpadCode
                && record.attemptCount == attemptCount
                && record.hintsRevealed == hintsRevealed
                && record.referenceViewed == referenceViewed
                && record.timeSpentSeconds == timeSpentSeconds
                && record.solvedAt == solvedAt
                && record.lastAttemptAt == lastAttemptAt
                && record.nextReviewAt == nextReviewAt
                && record.reviewLevel == reviewLevel
                && record.isFlaggedForReview == isFlaggedForReview
                && record.flaggedReviewAt == flaggedReviewAt
                && record.flaggedReviewLevel == flaggedReviewLevel
        }
    }
}
