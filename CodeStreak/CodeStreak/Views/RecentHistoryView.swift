import SwiftUI

struct RecentHistoryView: View {
    let records: [CompletionRecord]
    let now: Date
    let calendar: Calendar

    private var completedKeys: Set<String> {
        Set(records.filter(\.isCompleted).map(\.dayKey))
    }

    private var days: [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 6, to: now)
        }
    }

    var body: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Last seven days", systemImage: "calendar")
                    .appFont(.headline)

                HStack(spacing: 6) {
                    ForEach(days, id: \.self) { date in
                        let day = CalendarDay(date: date, calendar: calendar)
                        let isCompleted = completedKeys.contains(day.key)
                        let isToday = calendar.isDate(date, inSameDayAs: now)

                        VStack(spacing: 7) {
                            Text(date, format: .dateTime.weekday(.narrow))
                                .appFont(.caption2, weight: .semibold)
                                .foregroundStyle(.secondary)

                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                .appFont(.title3)
                                .foregroundStyle(isCompleted ? AppTheme.accent : Color.secondary)

                            Text(date, format: .dateTime.day())
                                .appFont(.caption, monospacedDigits: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 70)
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
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(
                            "\(date.formatted(.dateTime.weekday(.wide).day().month(.wide))), \(isCompleted ? "completed" : "not completed")"
                        )
                        .accessibilityAddTraits(isToday ? .isSelected : [])
                    }
                }
            }
        }
    }
}
