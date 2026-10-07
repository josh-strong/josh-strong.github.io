import Foundation
import Testing
#if SWIFT_PACKAGE
@testable import CodeStreakCore
#else
@testable import CodeStreak
#endif

struct WidgetProgressSnapshotTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    @Test func reportsTodayAndClampsProgress() {
        let now = Date(timeIntervalSince1970: 1_777_953_600)
        let snapshot = WidgetProgressSnapshot(
            solvedCount: 12,
            totalCount: 10,
            currentStreak: 4,
            latestCompletionAt: now.addingTimeInterval(-3_600),
            dueReviewCount: 2,
            nextProblemTitle: "Two Sum",
            updatedAt: now
        )

        #expect(snapshot.isCompletedToday(at: now, calendar: calendar))
        #expect(snapshot.displayedStreak(at: now, calendar: calendar) == 4)
        #expect(snapshot.progress == 1)
    }

    @Test func streakAllowsYesterdayButExpiresAfterAGap() {
        let now = Date(timeIntervalSince1970: 1_777_953_600)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let older = calendar.date(byAdding: .day, value: -2, to: now)!

        let current = makeSnapshot(latestCompletionAt: yesterday, now: now)
        let expired = makeSnapshot(latestCompletionAt: older, now: now)

        #expect(!current.isCompletedToday(at: now, calendar: calendar))
        #expect(current.displayedStreak(at: now, calendar: calendar) == 7)
        #expect(expired.displayedStreak(at: now, calendar: calendar) == 0)
    }

    @Test func futureCompletionCannotKeepAWidgetStreakAlive() {
        let now = Date(timeIntervalSince1970: 1_777_953_600)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let snapshot = makeSnapshot(latestCompletionAt: tomorrow, now: now)

        #expect(!snapshot.isCompletedToday(at: now, calendar: calendar))
        #expect(snapshot.displayedStreak(at: now, calendar: calendar) == 0)
    }

    private func makeSnapshot(latestCompletionAt: Date, now: Date) -> WidgetProgressSnapshot {
        WidgetProgressSnapshot(
            solvedCount: 20,
            totalCount: 174,
            currentStreak: 7,
            latestCompletionAt: latestCompletionAt,
            dueReviewCount: 0,
            nextProblemTitle: nil,
            updatedAt: now
        )
    }
}
