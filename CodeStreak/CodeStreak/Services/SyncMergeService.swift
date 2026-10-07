import Foundation
import SwiftData

struct SyncDayState: Codable, Equatable, Sendable {
    let dayKey: String
    let completedAt: Date
    let isCompleted: Bool
    let modifiedAt: Date
    let modifiedBy: String
}

struct SyncLearningState: Codable, Equatable, Sendable {
    let problemID: String
    let statusRaw: String
    let draftCode: String
    let notes: String
    let scratchpadCode: String?
    let attemptCount: Int
    let hintsRevealed: Int
    let referenceViewed: Bool
    let timeSpentSeconds: Int
    let solvedAt: Date?
    let lastAttemptAt: Date?
    let nextReviewAt: Date?
    let reviewLevel: Int
    let isFlaggedForReview: Bool?
    let flaggedReviewAt: Date?
    let flaggedReviewLevel: Int?
    let modifiedAt: Date
    let modifiedBy: String

    init(
        problemID: String,
        statusRaw: String,
        draftCode: String,
        notes: String,
        scratchpadCode: String?,
        attemptCount: Int,
        hintsRevealed: Int,
        referenceViewed: Bool,
        timeSpentSeconds: Int,
        solvedAt: Date?,
        lastAttemptAt: Date?,
        nextReviewAt: Date?,
        reviewLevel: Int,
        isFlaggedForReview: Bool? = nil,
        flaggedReviewAt: Date? = nil,
        flaggedReviewLevel: Int? = nil,
        modifiedAt: Date,
        modifiedBy: String
    ) {
        self.problemID = problemID
        self.statusRaw = statusRaw
        self.draftCode = draftCode
        self.notes = notes
        self.scratchpadCode = scratchpadCode
        self.attemptCount = attemptCount
        self.hintsRevealed = hintsRevealed
        self.referenceViewed = referenceViewed
        self.timeSpentSeconds = timeSpentSeconds
        self.solvedAt = solvedAt
        self.lastAttemptAt = lastAttemptAt
        self.nextReviewAt = nextReviewAt
        self.reviewLevel = reviewLevel
        self.isFlaggedForReview = isFlaggedForReview
        self.flaggedReviewAt = flaggedReviewAt
        self.flaggedReviewLevel = flaggedReviewLevel
        self.modifiedAt = modifiedAt
        self.modifiedBy = modifiedBy
    }
}

struct SyncEnvelope: Codable, Equatable, Sendable {
    static let currentVersion = 3

    let version: Int
    let senderDeviceID: String
    let senderName: String
    let states: [SyncDayState]
    let learningStates: [SyncLearningState]

    init(
        senderDeviceID: String,
        senderName: String,
        states: [SyncDayState],
        learningStates: [SyncLearningState] = []
    ) {
        version = Self.currentVersion
        self.senderDeviceID = senderDeviceID
        self.senderName = senderName
        self.states = states
        self.learningStates = learningStates
    }
}

struct SyncMergeSummary: Equatable, Sendable {
    let inserted: Int
    let updated: Int

    var changeCount: Int { inserted + updated }
}

enum SyncMergeError: LocalizedError {
    case unsupportedVersion

    var errorDescription: String? {
        "The nearby device is using an incompatible CodeStreak sync format."
    }
}

@MainActor
struct SyncMergeService {
    let localDeviceID: String

    func makeEnvelope(
        context: ModelContext,
        deviceName: String
    ) throws -> SyncEnvelope {
        let records = try context.fetch(FetchDescriptor<CompletionRecord>())
        let learningRecords = try context.fetch(FetchDescriptor<LearningProgressRecord>())
        var normalizedLegacyRecord = false

        for record in records where record.modifiedBy.isEmpty {
            record.modifiedBy = localDeviceID
            record.modifiedAt = record.completedAt
            normalizedLegacyRecord = true
        }

        for record in learningRecords where record.modifiedBy.isEmpty {
            record.modifiedBy = localDeviceID
            record.modifiedAt = record.lastAttemptAt ?? record.solvedAt ?? .now
            normalizedLegacyRecord = true
        }

        if normalizedLegacyRecord {
            try saveOrRollback(context)
        }

        let states = records.map {
            SyncDayState(
                dayKey: $0.dayKey,
                completedAt: $0.completedAt,
                isCompleted: $0.isCompleted,
                modifiedAt: $0.modifiedAt,
                modifiedBy: $0.modifiedBy
            )
        }
        .sorted { $0.dayKey < $1.dayKey }

        let learningStates = learningRecords.map {
            SyncLearningState(
                problemID: $0.problemID,
                statusRaw: $0.statusRaw,
                draftCode: $0.draftCode,
                notes: $0.notes,
                scratchpadCode: $0.scratchpadCode,
                attemptCount: $0.attemptCount,
                hintsRevealed: $0.hintsRevealed,
                referenceViewed: $0.referenceViewed,
                timeSpentSeconds: $0.timeSpentSeconds,
                solvedAt: $0.solvedAt,
                lastAttemptAt: $0.lastAttemptAt,
                nextReviewAt: $0.nextReviewAt,
                reviewLevel: $0.reviewLevel,
                isFlaggedForReview: $0.isFlaggedForReview,
                flaggedReviewAt: $0.flaggedReviewAt,
                flaggedReviewLevel: $0.flaggedReviewLevel,
                modifiedAt: $0.modifiedAt,
                modifiedBy: $0.modifiedBy
            )
        }
        .sorted { $0.problemID < $1.problemID }

        return SyncEnvelope(
            senderDeviceID: localDeviceID,
            senderName: deviceName,
            states: states,
            learningStates: learningStates
        )
    }

    func merge(
        _ envelope: SyncEnvelope,
        into context: ModelContext
    ) throws -> SyncMergeSummary {
        guard envelope.version == SyncEnvelope.currentVersion else {
            throw SyncMergeError.unsupportedVersion
        }

        let records = try context.fetch(FetchDescriptor<CompletionRecord>())
        let learningRecords = try context.fetch(FetchDescriptor<LearningProgressRecord>())
        var localByDay = Dictionary(uniqueKeysWithValues: records.map { ($0.dayKey, $0) })
        var localByProblem = Dictionary(uniqueKeysWithValues: learningRecords.map { ($0.problemID, $0) })
        let remoteByDay = newestStatesByDay(envelope.states)
        let remoteByProblem = newestLearningStatesByProblem(envelope.learningStates)
        var inserted = 0
        var updated = 0

        for state in remoteByDay.values {
            if let local = localByDay[state.dayKey] {
                guard remoteWins(state, over: local) else { continue }
                local.completedAt = state.completedAt
                local.isCompleted = state.isCompleted
                local.modifiedAt = state.modifiedAt
                local.modifiedBy = state.modifiedBy
                updated += 1
            } else {
                let record = CompletionRecord(
                    dayKey: state.dayKey,
                    completedAt: state.completedAt,
                    isCompleted: state.isCompleted,
                    modifiedAt: state.modifiedAt,
                    modifiedBy: state.modifiedBy
                )
                context.insert(record)
                localByDay[state.dayKey] = record
                inserted += 1
            }
        }


        for state in remoteByProblem.values {
            if let local = localByProblem[state.problemID] {
                guard learningStateWins(state, over: local) else { continue }
                apply(state, to: local)
                updated += 1
            } else {
                let record = LearningProgressRecord(
                    problemID: state.problemID,
                    status: LearningStatus(rawValue: state.statusRaw) ?? .notStarted,
                    draftCode: state.draftCode,
                    notes: state.notes,
                    scratchpadCode: state.scratchpadCode ?? "",
                    attemptCount: max(state.attemptCount, 0),
                    hintsRevealed: max(state.hintsRevealed, 0),
                    referenceViewed: state.referenceViewed,
                    timeSpentSeconds: state.timeSpentSeconds,
                    solvedAt: state.solvedAt,
                    lastAttemptAt: state.lastAttemptAt,
                    nextReviewAt: state.nextReviewAt,
                    reviewLevel: max(state.reviewLevel, 0),
                    isFlaggedForReview: state.isFlaggedForReview ?? false,
                    flaggedReviewAt: state.isFlaggedForReview == true
                        ? state.flaggedReviewAt ?? state.modifiedAt
                        : nil,
                    flaggedReviewLevel: max(state.flaggedReviewLevel ?? 0, 0),
                    modifiedAt: state.modifiedAt,
                    modifiedBy: state.modifiedBy
                )
                context.insert(record)
                localByProblem[state.problemID] = record
                inserted += 1
            }
        }

        if inserted > 0 || updated > 0 {
            try saveOrRollback(context)
            WidgetProgressExporter.refresh(context: context)
        }

        return SyncMergeSummary(inserted: inserted, updated: updated)
    }

    private func newestStatesByDay(_ states: [SyncDayState]) -> [String: SyncDayState] {
        states.reduce(into: [:]) { result, state in
            guard let existing = result[state.dayKey] else {
                result[state.dayKey] = state
                return
            }
            if stateWins(state, over: existing) {
                result[state.dayKey] = state
            }
        }
    }

    private func newestLearningStatesByProblem(_ states: [SyncLearningState]) -> [String: SyncLearningState] {
        states.reduce(into: [:]) { result, state in
            guard let existing = result[state.problemID] else {
                result[state.problemID] = state
                return
            }
            if state.modifiedAt > existing.modifiedAt ||
                (state.modifiedAt == existing.modifiedAt && state.modifiedBy > existing.modifiedBy) {
                result[state.problemID] = state
            }
        }
    }

    private func remoteWins(_ remote: SyncDayState, over local: CompletionRecord) -> Bool {
        if remote.modifiedAt != local.modifiedAt {
            return remote.modifiedAt > local.modifiedAt
        }
        return remote.modifiedBy > local.modifiedBy
    }

    private func stateWins(_ candidate: SyncDayState, over existing: SyncDayState) -> Bool {
        if candidate.modifiedAt != existing.modifiedAt {
            return candidate.modifiedAt > existing.modifiedAt
        }
        return candidate.modifiedBy > existing.modifiedBy
    }

    private func learningStateWins(_ remote: SyncLearningState, over local: LearningProgressRecord) -> Bool {
        if remote.modifiedAt != local.modifiedAt {
            return remote.modifiedAt > local.modifiedAt
        }
        return remote.modifiedBy > local.modifiedBy
    }

    private func apply(_ state: SyncLearningState, to record: LearningProgressRecord) {
        let localWasSolved = record.isSolved
        let localSolvedAt = record.solvedAt
        let localNextReviewAt = record.nextReviewAt
        let localReviewLevel = max(record.reviewLevel, 0)
        let localAttemptCount = max(record.attemptCount, 0)
        let localHintsRevealed = max(record.hintsRevealed, 0)
        let localReferenceViewed = record.referenceViewed
        let localLastAttemptAt = record.lastAttemptAt
        let remoteStatus = LearningStatus(rawValue: state.statusRaw) ?? .notStarted
        let remoteReviewLevel = max(state.reviewLevel, 0)

        record.status = remoteStatus
        record.draftCode = state.draftCode
        record.notes = state.notes
        if let scratchpadCode = state.scratchpadCode {
            record.scratchpadCode = scratchpadCode
        }
        // There are no user actions that "unsolve" a problem, remove an
        // attempt, hide an already revealed hint, or un-view a reference.
        // Preserve those monotonic learning facts when a newer draft from a
        // stale device wins the whole-record timestamp comparison.
        record.attemptCount = max(localAttemptCount, max(state.attemptCount, 0))
        record.hintsRevealed = max(localHintsRevealed, max(state.hintsRevealed, 0))
        record.referenceViewed = localReferenceViewed || state.referenceViewed
        record.timeSpentSeconds = max(state.timeSpentSeconds, 0)
        record.lastAttemptAt = later(localLastAttemptAt, state.lastAttemptAt)

        // Optional fields keep envelopes from older app versions compatible.
        // A missing value preserves the local flag; an explicit false is a
        // deliberate unflag action from an updated device.
        if let remoteIsFlagged = state.isFlaggedForReview {
            if remoteIsFlagged {
                let remoteFlagLevel = max(state.flaggedReviewLevel ?? 0, 0)
                if record.isFlaggedForReview && record.flaggedReviewLevel > remoteFlagLevel {
                    // Review acknowledgements only move forward while a flag
                    // remains active, so a stale newer draft cannot undo one.
                } else {
                    record.flaggedReviewLevel = remoteFlagLevel
                    record.flaggedReviewAt = state.flaggedReviewAt ?? state.modifiedAt
                }
                record.isFlaggedForReview = true
            } else {
                record.isFlaggedForReview = false
                record.flaggedReviewAt = nil
                record.flaggedReviewLevel = 0
            }
        }

        if localWasSolved && remoteStatus != .solved {
            record.status = .solved
            record.solvedAt = localSolvedAt
            record.nextReviewAt = localNextReviewAt
            record.reviewLevel = localReviewLevel
        } else if remoteStatus == .solved {
            record.solvedAt = earlier(localWasSolved ? localSolvedAt : nil, state.solvedAt)
            record.reviewLevel = max(localReviewLevel, remoteReviewLevel)
            record.nextReviewAt = localWasSolved && localReviewLevel > remoteReviewLevel
                ? localNextReviewAt
                : state.nextReviewAt
        } else {
            record.solvedAt = nil
            record.nextReviewAt = nil
            record.reviewLevel = 0
        }
        record.modifiedAt = state.modifiedAt
        record.modifiedBy = state.modifiedBy
    }

    private func earlier(_ lhs: Date?, _ rhs: Date?) -> Date? {
        return switch (lhs, rhs) {
        case let (lhs?, rhs?): min(lhs, rhs)
        case let (lhs?, nil): lhs
        case let (nil, rhs?): rhs
        case (nil, nil): nil
        }
    }

    private func later(_ lhs: Date?, _ rhs: Date?) -> Date? {
        return switch (lhs, rhs) {
        case let (lhs?, rhs?): max(lhs, rhs)
        case let (lhs?, nil): lhs
        case let (nil, rhs?): rhs
        case (nil, nil): nil
        }
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
