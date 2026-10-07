import Foundation
import XCTest

#if canImport(CodeStreak)
@testable import CodeStreak
#else
@testable import CodeStreakCore
#endif

final class StreakCalculatorTests: XCTestCase {
    private let calculator = StreakCalculator()

    func testNoCompletionRecords() {
        let calendar = makeCalendar()
        let now = makeDate(2026, 8, 4, calendar: calendar)

        XCTAssertEqual(calculator.calculate(completedDates: [], now: now, calendar: calendar), .empty)
    }

    func testTodayCompleted() {
        assertSummary(
            dates: [(2026, 8, 4)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 1, longestStreak: 1, totalCompletedDays: 1, isCompletedToday: true)
        )
    }

    func testYesterdayCompletedUsesGraceRule() {
        assertSummary(
            dates: [(2026, 8, 3)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 1, longestStreak: 1, totalCompletedDays: 1, isCompletedToday: false)
        )
    }

    func testTodayAndYesterdayCompleted() {
        assertSummary(
            dates: [(2026, 8, 3), (2026, 8, 4)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 2, longestStreak: 2, totalCompletedDays: 2, isCompletedToday: true)
        )
    }

    func testGapBeforeToday() {
        assertSummary(
            dates: [(2026, 8, 2), (2026, 8, 4)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 1, longestStreak: 1, totalCompletedDays: 2, isCompletedToday: true)
        )
    }

    func testGapOnYesterdayBreaksCurrentStreak() {
        assertSummary(
            dates: [(2026, 8, 2)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 0, longestStreak: 1, totalCompletedDays: 1, isCompletedToday: false)
        )
    }

    func testLongestStreakCanBeGreaterThanCurrentStreak() {
        assertSummary(
            dates: [(2026, 1, 1), (2026, 1, 2), (2026, 1, 3), (2026, 8, 3)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 1, longestStreak: 3, totalCompletedDays: 4, isCompletedToday: false)
        )
    }

    func testDuplicateCompletionDatesCountOnce() {
        let calendar = makeCalendar()
        let now = makeDate(2026, 8, 4, calendar: calendar)
        let morning = makeDate(2026, 8, 4, hour: 8, calendar: calendar)
        let evening = makeDate(2026, 8, 4, hour: 21, calendar: calendar)

        XCTAssertEqual(
            calculator.calculate(completedDates: [morning, evening, morning], now: now, calendar: calendar),
            StreakSummary(currentStreak: 1, longestStreak: 1, totalCompletedDays: 1, isCompletedToday: true)
        )
    }

    func testUnsortedInput() {
        assertSummary(
            dates: [(2026, 8, 4), (2026, 8, 2), (2026, 8, 3)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 3, longestStreak: 3, totalCompletedDays: 3, isCompletedToday: true)
        )
    }

    func testMonthBoundary() {
        assertSummary(
            dates: [(2026, 7, 31), (2026, 8, 1), (2026, 8, 2)],
            now: (2026, 8, 3),
            expected: StreakSummary(currentStreak: 3, longestStreak: 3, totalCompletedDays: 3, isCompletedToday: false)
        )
    }

    func testYearBoundary() {
        assertSummary(
            dates: [(2025, 12, 30), (2025, 12, 31), (2026, 1, 1)],
            now: (2026, 1, 1),
            expected: StreakSummary(currentStreak: 3, longestStreak: 3, totalCompletedDays: 3, isCompletedToday: true)
        )
    }

    func testLeapDay() {
        assertSummary(
            dates: [(2024, 2, 28), (2024, 2, 29), (2024, 3, 1)],
            now: (2024, 3, 1),
            expected: StreakSummary(currentStreak: 3, longestStreak: 3, totalCompletedDays: 3, isCompletedToday: true)
        )
    }

    func testDaylightSavingTransition() {
        let calendar = makeCalendar(timeZone: "Europe/London")
        let dates = [
            makeDate(2026, 3, 28, hour: 23, calendar: calendar),
            makeDate(2026, 3, 29, hour: 1, calendar: calendar),
            makeDate(2026, 3, 30, hour: 7, calendar: calendar)
        ]
        let now = makeDate(2026, 3, 30, hour: 20, calendar: calendar)

        XCTAssertEqual(
            calculator.calculate(completedDates: dates, now: now, calendar: calendar),
            StreakSummary(currentStreak: 3, longestStreak: 3, totalCompletedDays: 3, isCompletedToday: true)
        )
    }

    func testDifferentTimesOnSameDayAreOneCompletion() {
        let calendar = makeCalendar(timeZone: "America/New_York")
        let now = makeDate(2026, 11, 2, hour: 22, calendar: calendar)
        let dates = [
            makeDate(2026, 11, 1, hour: 1, calendar: calendar),
            makeDate(2026, 11, 1, hour: 23, calendar: calendar),
            makeDate(2026, 11, 2, hour: 6, calendar: calendar)
        ]

        XCTAssertEqual(
            calculator.calculate(completedDates: dates, now: now, calendar: calendar),
            StreakSummary(currentStreak: 2, longestStreak: 2, totalCompletedDays: 2, isCompletedToday: true)
        )
    }

    func testFutureCompletionIsIgnored() {
        assertSummary(
            dates: [(2026, 8, 4), (2026, 8, 5), (2027, 1, 1)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 1, longestStreak: 1, totalCompletedDays: 1, isCompletedToday: true)
        )
    }

    func testRecordFromMuchEarlierYearIsRetainedInTotals() {
        assertSummary(
            dates: [(1998, 6, 12), (2026, 8, 3)],
            now: (2026, 8, 4),
            expected: StreakSummary(currentStreak: 1, longestStreak: 1, totalCompletedDays: 2, isCompletedToday: false)
        )
    }

    func testDayKeyUsesCalendarComponents() {
        let calendar = makeCalendar(timeZone: "Pacific/Kiritimati")
        let date = makeDate(2026, 1, 2, hour: 0, calendar: calendar)

        XCTAssertEqual(CalendarDay(date: date, calendar: calendar).key, "2026-01-02")
    }

    private func assertSummary(
        dates: [(Int, Int, Int)],
        now: (Int, Int, Int),
        expected: StreakSummary,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let calendar = makeCalendar()
        let completedDates = dates.map { makeDate($0.0, $0.1, $0.2, calendar: calendar) }
        let nowDate = makeDate(now.0, now.1, now.2, calendar: calendar)
        XCTAssertEqual(
            calculator.calculate(completedDates: completedDates, now: nowDate, calendar: calendar),
            expected,
            file: file,
            line: line
        )
    }

    private func makeCalendar(timeZone identifier: String = "Europe/London") -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_GB")
        calendar.timeZone = TimeZone(identifier: identifier)!
        return calendar
    }

    private func makeDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 12,
        calendar: Calendar
    ) -> Date {
        let date = calendar.date(
            from: DateComponents(year: year, month: month, day: day, hour: hour)
        )
        return try! XCTUnwrap(date)
    }
}
