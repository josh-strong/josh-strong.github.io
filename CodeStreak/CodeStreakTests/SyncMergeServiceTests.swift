import SwiftData
import XCTest

@testable import CodeStreak

@MainActor
final class SyncMergeServiceTests: XCTestCase {
    private let localDeviceID = "local-device"

    func testMergeInsertsRemoteCompletion() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let remote = state(dayKey: "2026-08-04", completed: true, modifiedAt: 20, modifiedBy: "phone")

        let summary = try service.merge(envelope(states: [remote]), into: context)
        let records = try context.fetch(FetchDescriptor<CompletionRecord>())

        XCTAssertEqual(summary, SyncMergeSummary(inserted: 1, updated: 0))
        XCTAssertEqual(records.count, 1)
        XCTAssertTrue(try XCTUnwrap(records.first).isCompleted)
    }

    func testNewerRemoteUndoWins() throws {
        let container = try makeContainer()
        let context = container.mainContext
        context.insert(record(completed: true, modifiedAt: 10, modifiedBy: "mac"))
        try context.save()

        let remoteUndo = state(dayKey: "2026-08-04", completed: false, modifiedAt: 20, modifiedBy: "phone")
        let summary = try service.merge(envelope(states: [remoteUndo]), into: context)
        let merged = try XCTUnwrap(context.fetch(FetchDescriptor<CompletionRecord>()).first)

        XCTAssertEqual(summary.updated, 1)
        XCTAssertFalse(merged.isCompleted)
        XCTAssertEqual(merged.modifiedBy, "phone")
    }

    func testNewerLocalStateWins() throws {
        let container = try makeContainer()
        let context = container.mainContext
        context.insert(record(completed: true, modifiedAt: 30, modifiedBy: "mac"))
        try context.save()

        let olderUndo = state(dayKey: "2026-08-04", completed: false, modifiedAt: 20, modifiedBy: "phone")
        let summary = try service.merge(envelope(states: [olderUndo]), into: context)
        let merged = try XCTUnwrap(context.fetch(FetchDescriptor<CompletionRecord>()).first)

        XCTAssertEqual(summary, SyncMergeSummary(inserted: 0, updated: 0))
        XCTAssertTrue(merged.isCompleted)
        XCTAssertEqual(merged.modifiedBy, "mac")
    }

    func testDeviceIdentifierBreaksTimestampTieDeterministically() throws {
        let container = try makeContainer()
        let context = container.mainContext
        context.insert(record(completed: true, modifiedAt: 20, modifiedBy: "aaa"))
        try context.save()

        let tiedUndo = state(dayKey: "2026-08-04", completed: false, modifiedAt: 20, modifiedBy: "zzz")
        _ = try service.merge(envelope(states: [tiedUndo]), into: context)
        let merged = try XCTUnwrap(context.fetch(FetchDescriptor<CompletionRecord>()).first)

        XCTAssertFalse(merged.isCompleted)
        XCTAssertEqual(merged.modifiedBy, "zzz")
    }

    func testDuplicateRemoteStatesUseNewestVersion() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let older = state(dayKey: "2026-08-04", completed: true, modifiedAt: 10, modifiedBy: "phone")
        let newer = state(dayKey: "2026-08-04", completed: false, modifiedAt: 20, modifiedBy: "phone")

        _ = try service.merge(envelope(states: [newer, older]), into: context)
        let merged = try XCTUnwrap(context.fetch(FetchDescriptor<CompletionRecord>()).first)

        XCTAssertFalse(merged.isCompleted)
        XCTAssertEqual(try context.fetch(FetchDescriptor<CompletionRecord>()).count, 1)
    }

    func testEnvelopeNormalizesLegacyMetadata() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let completedAt = Date(timeIntervalSince1970: 100)
        context.insert(CompletionRecord(dayKey: "2026-08-04", completedAt: completedAt))
        try context.save()

        let snapshot = try service.makeEnvelope(context: context, deviceName: "My Mac")
        let state = try XCTUnwrap(snapshot.states.first)

        XCTAssertEqual(snapshot.senderDeviceID, localDeviceID)
        XCTAssertEqual(state.modifiedBy, localDeviceID)
        XCTAssertEqual(state.modifiedAt, completedAt)
    }

    func testMergeTransfersLearningDraftNotesAndScratchpad() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let learningState = SyncLearningState(
            problemID: "arrays.sum-positive",
            statusRaw: LearningStatus.inProgress.rawValue,
            draftCode: "def sum_positive(numbers):\n    return 1",
            notes: "Use an accumulator",
            scratchpadCode: "numbers = [1, -2, 3]\nprint(sum(numbers))",
            attemptCount: 2,
            hintsRevealed: 1,
            referenceViewed: false,
            timeSpentSeconds: 95,
            solvedAt: nil,
            lastAttemptAt: Date(timeIntervalSince1970: 10),
            nextReviewAt: nil,
            reviewLevel: 0,
            modifiedAt: Date(timeIntervalSince1970: 20),
            modifiedBy: "phone"
        )
        let envelope = SyncEnvelope(
            senderDeviceID: "remote-device",
            senderName: "iPhone",
            states: [],
            learningStates: [learningState]
        )

        let summary = try service.merge(envelope, into: context)
        let record = try XCTUnwrap(context.fetch(FetchDescriptor<LearningProgressRecord>()).first)

        XCTAssertEqual(summary.inserted, 1)
        XCTAssertEqual(record.draftCode, learningState.draftCode)
        XCTAssertEqual(record.notes, learningState.notes)
        XCTAssertEqual(record.scratchpadCode, learningState.scratchpadCode)
        XCTAssertEqual(record.hintsRevealed, 1)
        XCTAssertEqual(record.timeSpentSeconds, 95)
    }

    func testMergeTransfersFlaggedReviewScheduleAndNotes() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let reviewAt = Date(timeIntervalSince1970: 500_000)
        let learningState = SyncLearningState(
            problemID: "arrays.sum-positive",
            statusRaw: LearningStatus.inProgress.rawValue,
            draftCode: "def sum_positive(numbers):\n    return 0",
            notes: "I forgot the accumulator invariant.",
            scratchpadCode: nil,
            attemptCount: 1,
            hintsRevealed: 0,
            referenceViewed: false,
            timeSpentSeconds: 30,
            solvedAt: nil,
            lastAttemptAt: nil,
            nextReviewAt: nil,
            reviewLevel: 0,
            isFlaggedForReview: true,
            flaggedReviewAt: reviewAt,
            flaggedReviewLevel: 2,
            modifiedAt: Date(timeIntervalSince1970: 100),
            modifiedBy: "phone"
        )

        _ = try service.merge(
            SyncEnvelope(
                senderDeviceID: "remote-device",
                senderName: "iPhone",
                states: [],
                learningStates: [learningState]
            ),
            into: context
        )
        let record = try XCTUnwrap(context.fetch(FetchDescriptor<LearningProgressRecord>()).first)

        XCTAssertTrue(record.isFlaggedForReview)
        XCTAssertEqual(record.flaggedReviewAt, reviewAt)
        XCTAssertEqual(record.flaggedReviewLevel, 2)
        XCTAssertEqual(record.notes, learningState.notes)
    }

    func testExplicitNewerUnflagFromOtherDeviceClearsReviewSchedule() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let local = LearningProgressRecord(
            problemID: "arrays.sum-positive",
            status: .inProgress,
            isFlaggedForReview: true,
            flaggedReviewAt: Date(timeIntervalSince1970: 500),
            flaggedReviewLevel: 1,
            modifiedAt: Date(timeIntervalSince1970: 100),
            modifiedBy: "mac"
        )
        context.insert(local)
        try context.save()
        let unflagged = SyncLearningState(
            problemID: local.problemID,
            statusRaw: LearningStatus.inProgress.rawValue,
            draftCode: "",
            notes: "",
            scratchpadCode: nil,
            attemptCount: 0,
            hintsRevealed: 0,
            referenceViewed: false,
            timeSpentSeconds: 0,
            solvedAt: nil,
            lastAttemptAt: nil,
            nextReviewAt: nil,
            reviewLevel: 0,
            isFlaggedForReview: false,
            modifiedAt: Date(timeIntervalSince1970: 200),
            modifiedBy: "phone"
        )

        _ = try service.merge(
            SyncEnvelope(
                senderDeviceID: "remote-device",
                senderName: "iPhone",
                states: [],
                learningStates: [unflagged]
            ),
            into: context
        )

        XCTAssertFalse(local.isFlaggedForReview)
        XCTAssertNil(local.flaggedReviewAt)
        XCTAssertEqual(local.flaggedReviewLevel, 0)
    }

    func testNewerStaleDraftCannotEraseMonotonicSolvedProgress() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let solvedAt = Date(timeIntervalSince1970: 10)
        let nextReviewAt = Date(timeIntervalSince1970: 40)
        let local = LearningProgressRecord(
            problemID: "arrays.sum-positive",
            status: .solved,
            draftCode: "def sum_positive(numbers):\n    return sum(n for n in numbers if n > 0)",
            notes: "Solved locally",
            attemptCount: 5,
            hintsRevealed: 2,
            referenceViewed: true,
            solvedAt: solvedAt,
            lastAttemptAt: Date(timeIntervalSince1970: 20),
            nextReviewAt: nextReviewAt,
            reviewLevel: 2,
            modifiedAt: Date(timeIntervalSince1970: 25),
            modifiedBy: "mac"
        )
        context.insert(local)
        try context.save()

        let staleDraft = SyncLearningState(
            problemID: local.problemID,
            statusRaw: LearningStatus.inProgress.rawValue,
            draftCode: "def sum_positive(numbers):\n    return 0",
            notes: "Newer note from a stale phone",
            scratchpadCode: "print('phone experiment')",
            attemptCount: 1,
            hintsRevealed: 0,
            referenceViewed: false,
            timeSpentSeconds: 15,
            solvedAt: nil,
            lastAttemptAt: Date(timeIntervalSince1970: 5),
            nextReviewAt: nil,
            reviewLevel: 0,
            modifiedAt: Date(timeIntervalSince1970: 30),
            modifiedBy: "phone"
        )

        let summary = try service.merge(
            SyncEnvelope(
                senderDeviceID: "remote-device",
                senderName: "iPhone",
                states: [],
                learningStates: [staleDraft]
            ),
            into: context
        )

        XCTAssertEqual(summary.updated, 1)
        XCTAssertTrue(local.isSolved)
        XCTAssertEqual(local.solvedAt, solvedAt)
        XCTAssertEqual(local.nextReviewAt, nextReviewAt)
        XCTAssertEqual(local.reviewLevel, 2)
        XCTAssertEqual(local.attemptCount, 5)
        XCTAssertEqual(local.hintsRevealed, 2)
        XCTAssertTrue(local.referenceViewed)
        XCTAssertEqual(local.draftCode, staleDraft.draftCode)
        XCTAssertEqual(local.notes, staleDraft.notes)
        XCTAssertEqual(local.modifiedBy, "phone")
    }

    func testCorruptNegativeLearningCountersAreClampedDuringImport() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let corrupt = SyncLearningState(
            problemID: "arrays.sum-positive",
            statusRaw: LearningStatus.inProgress.rawValue,
            draftCode: "",
            notes: "",
            scratchpadCode: nil,
            attemptCount: -8,
            hintsRevealed: -3,
            referenceViewed: false,
            timeSpentSeconds: -100,
            solvedAt: nil,
            lastAttemptAt: nil,
            nextReviewAt: nil,
            reviewLevel: -2,
            modifiedAt: Date(timeIntervalSince1970: 20),
            modifiedBy: "phone"
        )

        _ = try service.merge(
            SyncEnvelope(
                senderDeviceID: "remote-device",
                senderName: "iPhone",
                states: [],
                learningStates: [corrupt]
            ),
            into: context
        )
        let record = try XCTUnwrap(context.fetch(FetchDescriptor<LearningProgressRecord>()).first)

        XCTAssertEqual(record.attemptCount, 0)
        XCTAssertEqual(record.hintsRevealed, 0)
        XCTAssertEqual(record.timeSpentSeconds, 0)
        XCTAssertEqual(record.reviewLevel, 0)
    }

    func testLegacyLearningEnvelopeWithoutScratchpadStillDecodes() throws {
        let state = SyncLearningState(
            problemID: "arrays.sum-positive",
            statusRaw: LearningStatus.inProgress.rawValue,
            draftCode: "def sum_positive(numbers):\n    return 1",
            notes: "Legacy device",
            scratchpadCode: "print('new field')",
            attemptCount: 1,
            hintsRevealed: 0,
            referenceViewed: false,
            timeSpentSeconds: 10,
            solvedAt: nil,
            lastAttemptAt: nil,
            nextReviewAt: nil,
            reviewLevel: 0,
            modifiedAt: Date(timeIntervalSince1970: 20),
            modifiedBy: "phone"
        )
        let envelope = SyncEnvelope(
            senderDeviceID: "remote-device",
            senderName: "Older iPhone",
            states: [],
            learningStates: [state]
        )
        let encoded = try JSONEncoder().encode(envelope)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        var learningStates = try XCTUnwrap(object["learningStates"] as? [[String: Any]])
        learningStates[0].removeValue(forKey: "scratchpadCode")
        learningStates[0].removeValue(forKey: "isFlaggedForReview")
        learningStates[0].removeValue(forKey: "flaggedReviewAt")
        learningStates[0].removeValue(forKey: "flaggedReviewLevel")
        object["learningStates"] = learningStates
        let legacyData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(SyncEnvelope.self, from: legacyData)

        XCTAssertNil(decoded.learningStates.first?.scratchpadCode)
        XCTAssertNil(decoded.learningStates.first?.isFlaggedForReview)
        XCTAssertNil(decoded.learningStates.first?.flaggedReviewAt)
        XCTAssertNil(decoded.learningStates.first?.flaggedReviewLevel)
        XCTAssertEqual(decoded.learningStates.first?.notes, "Legacy device")
    }

    private var service: SyncMergeService {
        SyncMergeService(localDeviceID: localDeviceID)
    }

    private func envelope(states: [SyncDayState]) -> SyncEnvelope {
        SyncEnvelope(senderDeviceID: "remote-device", senderName: "iPhone", states: states)
    }

    private func state(
        dayKey: String,
        completed: Bool,
        modifiedAt: TimeInterval,
        modifiedBy: String
    ) -> SyncDayState {
        SyncDayState(
            dayKey: dayKey,
            completedAt: Date(timeIntervalSince1970: 1),
            isCompleted: completed,
            modifiedAt: Date(timeIntervalSince1970: modifiedAt),
            modifiedBy: modifiedBy
        )
    }

    private func record(
        completed: Bool,
        modifiedAt: TimeInterval,
        modifiedBy: String
    ) -> CompletionRecord {
        CompletionRecord(
            dayKey: "2026-08-04",
            completedAt: Date(timeIntervalSince1970: 1),
            isCompleted: completed,
            modifiedAt: Date(timeIntervalSince1970: modifiedAt),
            modifiedBy: modifiedBy
        )
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
