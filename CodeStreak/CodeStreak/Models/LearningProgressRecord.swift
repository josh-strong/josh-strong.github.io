import Foundation
import SwiftData

enum LearningStatus: String, Codable, Sendable {
    case notStarted
    case inProgress
    case solved
}

@Model
final class LearningProgressRecord {
    @Attribute(.unique) var problemID: String
    var statusRaw: String = LearningStatus.notStarted.rawValue
    var draftCode: String = ""
    var notes: String = ""
    var scratchpadCode: String = ""
    var attemptCount: Int = 0
    var hintsRevealed: Int = 0
    var referenceViewed: Bool = false
    var timeSpentSeconds: Int = 0
    var solvedAt: Date?
    var lastAttemptAt: Date?
    var nextReviewAt: Date?
    var reviewLevel: Int = 0
    var isFlaggedForReview: Bool = false
    var flaggedReviewAt: Date?
    var flaggedReviewLevel: Int = 0
    var modifiedAt: Date = Date.distantPast
    var modifiedBy: String = ""

    init(
        problemID: String,
        status: LearningStatus = .notStarted,
        draftCode: String = "",
        notes: String = "",
        scratchpadCode: String = "",
        attemptCount: Int = 0,
        hintsRevealed: Int = 0,
        referenceViewed: Bool = false,
        timeSpentSeconds: Int = 0,
        solvedAt: Date? = nil,
        lastAttemptAt: Date? = nil,
        nextReviewAt: Date? = nil,
        reviewLevel: Int = 0,
        isFlaggedForReview: Bool = false,
        flaggedReviewAt: Date? = nil,
        flaggedReviewLevel: Int = 0,
        modifiedAt: Date = .now,
        modifiedBy: String = ""
    ) {
        self.problemID = problemID
        statusRaw = status.rawValue
        self.draftCode = draftCode
        self.notes = notes
        self.scratchpadCode = scratchpadCode
        self.attemptCount = attemptCount
        self.hintsRevealed = hintsRevealed
        self.referenceViewed = referenceViewed
        self.timeSpentSeconds = max(timeSpentSeconds, 0)
        self.solvedAt = solvedAt
        self.lastAttemptAt = lastAttemptAt
        self.nextReviewAt = nextReviewAt
        self.reviewLevel = reviewLevel
        self.isFlaggedForReview = isFlaggedForReview
        self.flaggedReviewAt = isFlaggedForReview ? flaggedReviewAt : nil
        self.flaggedReviewLevel = isFlaggedForReview ? max(flaggedReviewLevel, 0) : 0
        self.modifiedAt = modifiedAt
        self.modifiedBy = modifiedBy
    }

    var status: LearningStatus {
        get { LearningStatus(rawValue: statusRaw) ?? .notStarted }
        set { statusRaw = newValue.rawValue }
    }

    var isSolved: Bool { status == .solved }
}
