import SwiftData
import XCTest

@testable import CodeStreak

@MainActor
final class LearningProgressServiceTests: XCTestCase {
    private let service = LearningProgressService()

    func testCreatingProgressUsesPythonStarterCode() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)

        let record = try service.record(for: problem, context: container.mainContext)

        XCTAssertEqual(record.problemID, problem.id)
        XCTAssertEqual(record.draftCode, problem.starterCode)
        XCTAssertTrue(record.draftCode.hasPrefix("def "))
        XCTAssertEqual(record.status, .notStarted)
    }

    func testFirstPassingRunSolvesAndSchedulesReview() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let date = Date(timeIntervalSince1970: 1_000_000)

        let milestone = try service.recordRun(
            record,
            passed: true,
            at: date,
            calendar: utcCalendar,
            context: container.mainContext
        )

        XCTAssertEqual(milestone, .firstSolve)
        XCTAssertTrue(record.isSolved)
        XCTAssertEqual(record.solvedAt, date)
        XCTAssertEqual(record.nextReviewAt, utcCalendar.date(byAdding: .day, value: 1, to: date))
    }

    func testPlanUnlocksEveryProblemInCurrentModulesButNoLaterModule() throws {
        let firstAlgorithmModule = try XCTUnwrap(Curriculum.modules.first)
        let secondAlgorithmModule = Curriculum.modules[1]
        let firstMLModule = try XCTUnwrap(Curriculum.mlInterviewModules.first)
        let firstAlgorithm = try XCTUnwrap(firstAlgorithmModule.problems.first)
        let firstML = try XCTUnwrap(firstMLModule.problems.first)

        let snapshot = LearningPlanEngine().snapshot(records: [])
        let expectedAccessible = Set(
            (firstAlgorithmModule.problems + firstMLModule.problems).map(\.id)
        )
        XCTAssertEqual(snapshot.nextProblemID, firstAlgorithm.id)
        XCTAssertEqual(snapshot.nextMLProblemID, firstML.id)
        XCTAssertEqual(snapshot.accessibleIDs, expectedAccessible)
        XCTAssertTrue(firstAlgorithmModule.problems.allSatisfy {
            snapshot.accessibleIDs.contains($0.id)
        })
        XCTAssertTrue(firstMLModule.problems.allSatisfy {
            snapshot.accessibleIDs.contains($0.id)
        })
        XCTAssertTrue(secondAlgorithmModule.problems.allSatisfy {
            !snapshot.accessibleIDs.contains($0.id)
        })
    }

    func testNextModuleUnlocksOnlyAfterEveryCurrentModuleProblemIsSolved() throws {
        let container = try makeContainer()
        let firstModule = try XCTUnwrap(Curriculum.modules.first)
        let secondModule = Curriculum.modules[1]
        let lastProblem = try XCTUnwrap(firstModule.problems.last)
        var records: [LearningProgressRecord] = []

        // Solving out of order must not open the next module.
        let lastRecord = try service.record(for: lastProblem, context: container.mainContext)
        _ = try service.recordRun(lastRecord, passed: true, context: container.mainContext)
        records.append(lastRecord)

        var snapshot = LearningPlanEngine().snapshot(records: records)
        XCTAssertEqual(snapshot.nextProblemID, firstModule.problems.first?.id)
        XCTAssertTrue(firstModule.problems.allSatisfy { snapshot.accessibleIDs.contains($0.id) })
        XCTAssertTrue(secondModule.problems.allSatisfy { !snapshot.accessibleIDs.contains($0.id) })

        for problem in firstModule.problems.dropLast() {
            let record = try service.record(for: problem, context: container.mainContext)
            _ = try service.recordRun(record, passed: true, context: container.mainContext)
            records.append(record)
        }

        snapshot = LearningPlanEngine().snapshot(records: records)
        XCTAssertEqual(snapshot.nextProblemID, secondModule.problems.first?.id)
        XCTAssertTrue(secondModule.problems.allSatisfy { snapshot.accessibleIDs.contains($0.id) })
        XCTAssertTrue(firstModule.problems.allSatisfy { snapshot.accessibleIDs.contains($0.id) })
    }

    func testMLInterviewTrackAdvancesWithoutChangingAlgorithmMission() throws {
        let container = try makeContainer()
        let firstAlgorithm = try XCTUnwrap(Curriculum.algorithmProblems.first)
        let firstML = try XCTUnwrap(Curriculum.mlInterviewProblems.first)
        let secondML = Curriculum.mlInterviewProblems[1]
        let record = try service.record(for: firstML, context: container.mainContext)

        _ = try service.recordRun(record, passed: true, context: container.mainContext)
        let snapshot = LearningPlanEngine().snapshot(records: [record])

        XCTAssertEqual(snapshot.nextProblemID, firstAlgorithm.id)
        XCTAssertEqual(snapshot.nextMLProblemID, secondML.id)
        XCTAssertTrue(snapshot.accessibleIDs.isSuperset(of: [firstAlgorithm.id, firstML.id, secondML.id]))
    }

    func testDueReviewAdvancesSpacingLevel() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let firstDate = Date(timeIntervalSince1970: 1_000_000)
        _ = try service.recordRun(record, passed: true, at: firstDate, calendar: utcCalendar, context: container.mainContext)
        let dueDate = try XCTUnwrap(record.nextReviewAt)

        let milestone = try service.recordRun(record, passed: true, at: dueDate, calendar: utcCalendar, context: container.mainContext)

        XCTAssertEqual(milestone, .reviewCompleted(level: 1))
        XCTAssertEqual(record.reviewLevel, 1)
        XCTAssertEqual(record.nextReviewAt, utcCalendar.date(byAdding: .day, value: 3, to: dueDate))
    }

    func testFlaggedProblemBecomesDueAfterThreeDaysAndKeepsItsNotes() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let flaggedAt = Date(timeIntervalSince1970: 1_000_000)
        let expectedDue = try XCTUnwrap(
            utcCalendar.date(byAdding: .day, value: 3, to: flaggedAt)
        )

        try service.saveDraft(
            record,
            forProblemID: problem.id,
            code: problem.starterCode,
            notes: "Remember why the set lookup is O(1).",
            context: container.mainContext
        )
        let due = try service.flagForReview(
            record,
            at: flaggedAt,
            calendar: utcCalendar,
            context: container.mainContext
        )

        XCTAssertTrue(record.isFlaggedForReview)
        XCTAssertEqual(record.status, .inProgress)
        XCTAssertEqual(record.notes, "Remember why the set lookup is O(1).")
        XCTAssertEqual(record.flaggedReviewLevel, 0)
        XCTAssertEqual(due, expectedDue)
        XCTAssertTrue(
            LearningPlanEngine()
                .snapshot(records: [record], now: expectedDue.addingTimeInterval(-1))
                .flaggedReviewIDs
                .isEmpty
        )

        let duePlan = LearningPlanEngine().snapshot(records: [record], now: expectedDue)
        XCTAssertEqual(duePlan.flaggedReviewIDs, [problem.id])
        XCTAssertEqual(duePlan.dueReviewIDs, [problem.id])
    }

    func testCompletingFlaggedReviewSpacesItAgainAndClearRemovesIt() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let start = Date(timeIntervalSince1970: 1_000_000)
        _ = try service.flagForReview(
            record,
            at: start,
            calendar: utcCalendar,
            context: container.mainContext
        )
        let firstDue = try XCTUnwrap(record.flaggedReviewAt)

        let nextDue = try service.completeFlaggedReview(
            record,
            at: firstDue,
            calendar: utcCalendar,
            context: container.mainContext
        )

        XCTAssertTrue(record.isFlaggedForReview)
        XCTAssertEqual(record.flaggedReviewLevel, 1)
        XCTAssertEqual(nextDue, utcCalendar.date(byAdding: .day, value: 7, to: firstDue))
        XCTAssertTrue(
            LearningPlanEngine().snapshot(records: [record], now: firstDue).flaggedReviewIDs.isEmpty
        )

        try service.clearReviewFlag(record, at: firstDue, context: container.mainContext)

        XCTAssertFalse(record.isFlaggedForReview)
        XCTAssertNil(record.flaggedReviewAt)
        XCTAssertEqual(record.flaggedReviewLevel, 0)
        XCTAssertTrue(
            LearningPlanEngine().snapshot(records: [record], now: .distantFuture).flaggedReviewIDs.isEmpty
        )
    }

    func testStudyTimerAccumulatesPersistsAndCanReset() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let firstPause = Date(timeIntervalSince1970: 100)

        try service.addStudyTime(record, seconds: 61, at: firstPause, context: container.mainContext)
        try service.addStudyTime(record, seconds: 4, at: firstPause.addingTimeInterval(4), context: container.mainContext)

        XCTAssertEqual(record.timeSpentSeconds, 65)
        XCTAssertEqual(record.status, .inProgress)
        XCTAssertEqual(record.modifiedAt, firstPause.addingTimeInterval(4))

        let descriptor = FetchDescriptor<LearningProgressRecord>()
        XCTAssertEqual(try container.mainContext.fetch(descriptor).first?.timeSpentSeconds, 65)

        try service.resetStudyTime(record, at: firstPause.addingTimeInterval(5), context: container.mainContext)
        XCTAssertEqual(record.timeSpentSeconds, 0)
    }

    func testStudyTimerIgnoresNonpositiveElapsedTime() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)

        try service.addStudyTime(record, seconds: 0, context: container.mainContext)
        try service.addStudyTime(record, seconds: -5, context: container.mainContext)

        XCTAssertEqual(record.timeSpentSeconds, 0)
        XCTAssertEqual(record.status, .notStarted)
    }

    func testScratchpadPersistsSeparatelyFromTheSubmittedSolution() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let experiment = "values = [3, 1, 2]\nprint(sorted(values))"

        try service.saveDraft(
            record,
            forProblemID: problem.id,
            code: problem.starterCode,
            notes: "",
            scratchpadCode: experiment,
            context: container.mainContext
        )

        let persisted = try XCTUnwrap(
            container.mainContext.fetch(FetchDescriptor<LearningProgressRecord>()).first
        )
        XCTAssertEqual(persisted.draftCode, problem.starterCode)
        XCTAssertEqual(persisted.scratchpadCode, experiment)
        XCTAssertEqual(persisted.status, .inProgress)
        XCTAssertEqual(persisted.attemptCount, 0)
    }

    func testSavingAnUnchangedWorkspaceDoesNotCreateANewerSyncVersion() throws {
        let container = try makeContainer()
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let record = try service.record(for: problem, context: container.mainContext)
        let originalModifiedAt = record.modifiedAt
        let originalModifiedBy = record.modifiedBy

        try service.saveDraft(
            record,
            forProblemID: problem.id,
            code: problem.starterCode,
            notes: "",
            scratchpadCode: PythonScratchpad.starterCode,
            context: container.mainContext
        )

        XCTAssertEqual(record.modifiedAt, originalModifiedAt)
        XCTAssertEqual(record.modifiedBy, originalModifiedBy)
        XCTAssertEqual(record.scratchpadCode, "")
        XCTAssertEqual(record.status, .notStarted)
    }

    func testPlanIgnoresSolvedRecordsFromAnUnknownCurriculumVersion() {
        let known = LearningProgressRecord(
            problemID: Curriculum.allProblems[0].id,
            status: .solved,
            nextReviewAt: .distantPast
        )
        let unknown = LearningProgressRecord(
            problemID: "future-module.not-in-this-build",
            status: .solved,
            nextReviewAt: .distantPast
        )

        let plan = LearningPlanEngine().snapshot(records: [known, unknown], now: .now)

        XCTAssertEqual(plan.solvedIDs, [known.problemID])
        XCTAssertEqual(plan.dueReviewIDs, [known.problemID])
        XCTAssertFalse(plan.accessibleIDs.contains(unknown.problemID))
    }

    func testDraftSaveRejectsARecordFromAnotherProblem() throws {
        let container = try makeContainer()
        let first = try XCTUnwrap(Curriculum.allProblems.first)
        let second = Curriculum.allProblems[1]
        let firstRecord = try service.record(for: first, context: container.mainContext)

        XCTAssertThrowsError(
            try service.saveDraft(
                firstRecord,
                forProblemID: second.id,
                code: "def wrong_problem():\n    return True",
                notes: "This must not leak.",
                context: container.mainContext
            )
        ) { error in
            XCTAssertEqual(error as? LearningProgressServiceError, .problemMismatch)
        }

        XCTAssertEqual(firstRecord.draftCode, first.starterCode)
        XCTAssertTrue(firstRecord.notes.isEmpty)
    }

    func testRepeatedMasteryProgressMigratesIntoOneCanonicalProblemWithoutDataLoss() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let canonical = try XCTUnwrap(
            Curriculum.problem(withID: "mastery.arrays-hashing.missing-number")
        )
        let solvedAt = Date(timeIntervalSince1970: 100)
        let reviewAt = Date(timeIntervalSince1970: 200)
        let flagAt = Date(timeIntervalSince1970: 300)
        let foundationFunction = "\(canonical.functionName)_practice_1"
        let speedFunction = "\(canonical.functionName)_practice_4"
        let foundation = LearningProgressRecord(
            problemID: "\(canonical.id).1",
            status: .solved,
            draftCode: "def \(foundationFunction)(numbers):\n    return 99",
            notes: "I first used expected sum.",
            attemptCount: 3,
            hintsRevealed: 2,
            referenceViewed: true,
            timeSpentSeconds: 420,
            solvedAt: solvedAt,
            lastAttemptAt: solvedAt,
            nextReviewAt: reviewAt,
            reviewLevel: 1,
            modifiedAt: Date(timeIntervalSince1970: 150),
            modifiedBy: "old-mac"
        )
        let speedRound = LearningProgressRecord(
            problemID: "\(canonical.id).4",
            status: .inProgress,
            draftCode: "def \(speedFunction)(numbers):\n    return len(numbers)",
            notes: "Remember the empty input.",
            scratchpadCode: "print(\(speedFunction)([0, 1]))",
            attemptCount: 2,
            hintsRevealed: 1,
            timeSpentSeconds: 180,
            isFlaggedForReview: true,
            flaggedReviewAt: flagAt,
            flaggedReviewLevel: 2,
            modifiedAt: Date(timeIntervalSince1970: 250),
            modifiedBy: "old-phone"
        )
        context.insert(foundation)
        context.insert(speedRound)
        try context.save()

        let migration = CurriculumProgressMigrationService()
        XCTAssertEqual(
            try migration.migrate(context: context, at: Date(timeIntervalSince1970: 400)),
            1
        )
        let canonicalID = canonical.id
        let descriptor = FetchDescriptor<LearningProgressRecord>(
            predicate: #Predicate { $0.problemID == canonicalID }
        )
        let migrated = try XCTUnwrap(context.fetch(descriptor).first)

        XCTAssertTrue(migrated.isSolved)
        XCTAssertEqual(migrated.solvedAt, solvedAt)
        XCTAssertEqual(migrated.reviewLevel, 1)
        XCTAssertEqual(migrated.nextReviewAt, reviewAt)
        XCTAssertEqual(migrated.attemptCount, 3)
        XCTAssertEqual(migrated.hintsRevealed, 2)
        XCTAssertTrue(migrated.referenceViewed)
        XCTAssertEqual(migrated.timeSpentSeconds, 420)
        XCTAssertTrue(migrated.isFlaggedForReview)
        XCTAssertEqual(migrated.flaggedReviewAt, flagAt)
        XCTAssertEqual(migrated.flaggedReviewLevel, 2)
        XCTAssertTrue(migrated.draftCode.contains("def \(canonical.functionName)(numbers)"))
        XCTAssertTrue(migrated.draftCode.contains("return len(numbers)"))
        XCTAssertFalse(migrated.draftCode.contains("practice_4"))
        XCTAssertTrue(migrated.scratchpadCode.contains("\(canonical.functionName)([0, 1])"))
        XCTAssertTrue(migrated.notes.contains("Remember the empty input."))
        XCTAssertTrue(migrated.notes.contains("I first used expected sum."))
        XCTAssertTrue(migrated.notes.contains("return 99"), "The displaced earlier draft must remain recoverable in notes")

        let notesAfterFirstMigration = migrated.notes
        let modifiedAfterFirstMigration = migrated.modifiedAt
        XCTAssertEqual(
            try migration.migrate(context: context, at: Date(timeIntervalSince1970: 500)),
            0,
            "Running the migration again must not duplicate notes or manufacture a newer sync edit"
        )
        XCTAssertEqual(migrated.notes, notesAfterFirstMigration)
        XCTAssertEqual(migrated.modifiedAt, modifiedAfterFirstMigration)
    }

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: CompletionRecord.self,
            LearningProgressRecord.self,
            configurations: configuration
        )
    }
}
