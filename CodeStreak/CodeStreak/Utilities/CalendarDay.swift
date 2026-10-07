import Foundation

/// A calendar-relative day without a time-of-day component.
struct CalendarDay: Hashable, Comparable, Sendable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        precondition(
            components.year != nil && components.month != nil && components.day != nil,
            "The selected calendar could not represent this date."
        )
        year = components.year!
        month = components.month!
        day = components.day!
    }

    var key: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    func date(in calendar: Calendar) -> Date? {
        // Noon avoids edge cases in calendars/time zones where local midnight is skipped.
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
    }

    func adding(days: Int, calendar: Calendar) -> CalendarDay? {
        guard
            let date = date(in: calendar),
            let adjusted = calendar.date(byAdding: .day, value: days, to: date)
        else {
            return nil
        }
        return CalendarDay(date: adjusted, calendar: calendar)
    }

    static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
