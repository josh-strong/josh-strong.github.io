import Foundation

struct StreakSummary: Equatable, Sendable {
    let currentStreak: Int
    let longestStreak: Int
    let totalCompletedDays: Int
    let isCompletedToday: Bool

    static let empty = StreakSummary(
        currentStreak: 0,
        longestStreak: 0,
        totalCompletedDays: 0,
        isCompletedToday: false
    )
}

struct StreakCalculator: Sendable {
    func calculate(
        completedDates: [Date],
        now: Date,
        calendar: Calendar
    ) -> StreakSummary {
        let today = CalendarDay(date: now, calendar: calendar)
        let completedDays = Set(
            completedDates.compactMap { date -> CalendarDay? in
                guard calendar.compare(date, to: now, toGranularity: .day) != .orderedDescending else {
                    return nil
                }
                return CalendarDay(date: date, calendar: calendar)
            }
        )

        guard !completedDays.isEmpty else { return .empty }

        let isCompletedToday = completedDays.contains(today)
        let currentAnchor = isCompletedToday ? today : today.adding(days: -1, calendar: calendar)
        let currentStreak = countBackwards(
            from: currentAnchor,
            completedDays: completedDays,
            calendar: calendar
        )

        var longestStreak = 0
        var runningStreak = 0
        var previous: CalendarDay?

        for day in completedDays.sorted() {
            if let previous, previous.adding(days: 1, calendar: calendar) == day {
                runningStreak += 1
            } else {
                runningStreak = 1
            }
            longestStreak = max(longestStreak, runningStreak)
            previous = day
        }

        return StreakSummary(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalCompletedDays: completedDays.count,
            isCompletedToday: isCompletedToday
        )
    }

    private func countBackwards(
        from anchor: CalendarDay?,
        completedDays: Set<CalendarDay>,
        calendar: Calendar
    ) -> Int {
        guard var day = anchor else { return 0 }
        var count = 0

        while completedDays.contains(day) {
            count += 1
            guard let previous = day.adding(days: -1, calendar: calendar) else { break }
            day = previous
        }
        return count
    }
}
