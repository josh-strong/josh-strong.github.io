import SwiftUI

struct StreakSummaryView: View {
    let summary: StreakSummary

    var body: some View {
        LearningCard {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .appFont(fixedSize: 32, weight: .semibold)
                        .foregroundStyle(.orange)
                        .accessibilityHidden(true)

                    Text(summary.currentStreak, format: .number)
                        .appFont(.largeTitle, weight: .bold, design: .rounded)
                        .contentTransition(.numericText())

                    Text("day streak")
                        .appFont(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Current streak, \(summary.currentStreak) days")

                Divider()

                HStack(spacing: 24) {
                    metric(title: "Longest", value: summary.longestStreak, symbol: "trophy.fill")
                    metric(title: "Completed", value: summary.totalCompletedDays, symbol: "checkmark.circle.fill")
                }
            }
        }
    }

    private func metric(title: String, value: Int, symbol: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(value, format: .number)
                    .appFont(.title3, weight: .bold)
                Text(title)
                    .appFont(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value) days")
    }
}
