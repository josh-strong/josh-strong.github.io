import SwiftUI

struct HistoryView: View {
    let records: [CompletionRecord]
    let now: Date
    let calendar: Calendar

    @State private var displayedMonth: Date

    init(records: [CompletionRecord], now: Date, calendar: Calendar) {
        self.records = records
        self.now = now
        self.calendar = calendar
        _displayedMonth = State(initialValue: Self.startOfMonth(containing: now, calendar: calendar))
    }

    var body: some View {
        ScrollView {
            LearningCard {
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            moveMonth(by: -1)
                        } label: {
                            Label("Previous month", systemImage: "chevron.left")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.leftArrow, modifiers: [])

                        Spacer()

                        Text(displayedMonth, format: .dateTime.month(.wide).year())
                            .appFont(.title2, weight: .bold)
                            .accessibilityAddTraits(.isHeader)

                        Spacer()

                        Button {
                            moveMonth(by: 1)
                        } label: {
                            Label("Next month", systemImage: "chevron.right")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.rightArrow, modifiers: [])
                        .disabled(isShowingCurrentMonth)
                    }

                    CalendarGridView(
                        month: displayedMonth,
                        records: records,
                        now: now,
                        calendar: calendar
                    )
                }
            }
            .frame(maxWidth: 680)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("History")
        .learningBackground()
    }

    private var isShowingCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: now, toGranularity: .month)
    }

    private func moveMonth(by amount: Int) {
        guard let candidate = calendar.date(byAdding: .month, value: amount, to: displayedMonth) else {
            return
        }
        let currentMonth = Self.startOfMonth(containing: now, calendar: calendar)
        displayedMonth = min(candidate, currentMonth)
    }

    private static func startOfMonth(containing date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}
