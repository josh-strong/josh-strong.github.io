import SwiftUI

struct CalendarGridView: View {
    let month: Date
    let records: [CompletionRecord]
    let now: Date
    let calendar: Calendar

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var completedKeys: Set<String> {
        Set(records.filter(\.isCompleted).map(\.dayKey))
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let offset = max(calendar.firstWeekday - 1, 0)
        return Array(symbols[offset...] + symbols[..<offset])
    }

    private var gridDates: [Date?] {
        guard
            let dayRange = calendar.range(of: .day, in: .month, for: month),
            let firstDay = calendar.date(
                from: calendar.dateComponents([.year, .month], from: month)
            )
        else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingSlots = (weekday - calendar.firstWeekday + 7) % 7
        let dates = dayRange.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
        return Array(repeating: nil, count: leadingSlots) + dates.map(Optional.some)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .appFont(.caption, weight: .semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }

            ForEach(Array(gridDates.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear
                        .frame(minHeight: 58)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let day = CalendarDay(date: date, calendar: calendar)
        let isCompleted = completedKeys.contains(day.key)
        let isToday = calendar.isDate(date, inSameDayAs: now)
        let isFuture = calendar.compare(date, to: now, toGranularity: .day) == .orderedDescending

        return VStack(spacing: 5) {
            Text(date, format: .dateTime.day())
                .appFont(.body, weight: isToday ? .bold : .regular, monospacedDigits: true)

            Image(systemName: isCompleted ? "checkmark.circle.fill" : (isFuture ? "minus" : "circle"))
                .appFont(.body)
                .foregroundStyle(
                    isCompleted ? AppTheme.accent : (isFuture ? Color.secondary.opacity(0.4) : Color.secondary)
                )
        }
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(
            isToday ? AppTheme.accent.opacity(0.10) : Color.clear,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .overlay {
            if isToday {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.accent.opacity(0.55), lineWidth: 1)
            }
        }
        .opacity(isFuture ? 0.65 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(for: date, isCompleted: isCompleted, isFuture: isFuture))
        .accessibilityAddTraits(isToday ? .isSelected : [])
    }

    private func accessibilityLabel(for date: Date, isCompleted: Bool, isFuture: Bool) -> String {
        let dateLabel = date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
        if isFuture {
            return "\(dateLabel), future date"
        }
        return "\(dateLabel), \(isCompleted ? "completed" : "not completed")"
    }
}
