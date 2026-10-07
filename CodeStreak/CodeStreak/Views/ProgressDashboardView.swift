import SwiftData
import SwiftUI

struct ProgressDashboardView: View {
    @Query private var progressRecords: [LearningProgressRecord]
    @Query(sort: \CompletionRecord.completedAt, order: .reverse) private var completionRecords: [CompletionRecord]
    private let engine = LearningPlanEngine()
    private let calendar = Calendar.autoupdatingCurrent

    private var solved: [LearningProgressRecord] {
        progressRecords.filter { $0.isSolved && Curriculum.problem(withID: $0.problemID) != nil }
    }
    private var recognizedProgressRecords: [LearningProgressRecord] {
        progressRecords.filter { Curriculum.problem(withID: $0.problemID) != nil }
    }
    private var plan: LearningPlanSnapshot { engine.snapshot(records: progressRecords) }
    private var completionFraction: Double {
        Double(solved.count) / Double(max(Curriculum.allProblems.count, 1))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                overviewCard
                weeklyCard
                difficultyCard
                trackMastery
                learningSignals

                NavigationLink {
                    HistoryView(records: completionRecords.filter(\.isCompleted), now: .now, calendar: calendar)
                } label: {
                    Label("Open full practice calendar", systemImage: "calendar")
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .frame(maxWidth: 780, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Progress")
        .learningBackground()
    }

    private var overviewCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(AppTheme.accent.opacity(0.13), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: completionFraction)
                            .stroke(
                                AppTheme.accent,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 0) {
                            Text("\(solved.count)").appFont(.title2, weight: .bold)
                            Text("solved").appFont(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 104, height: 104)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Your interview toolkit").appFont(.title3, weight: .bold)
                        Text("\(Int(completionFraction * 100))% of the structured path")
                            .appFont(.subheadline)
                            .foregroundStyle(.secondary)
                        if plan.dueReviewIDs.isEmpty {
                            Label("Reviews are up to date", systemImage: "checkmark.seal.fill")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(.green)
                        } else {
                            Label("\(plan.dueReviewIDs.count) review\(plan.dueReviewIDs.count == 1 ? "" : "s") due", systemImage: "brain.fill")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                }

                ProgressView(value: completionFraction)
                    .tint(AppTheme.accent)
            }
        }
    }

    private var weeklyCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Last seven days", systemImage: "flame.fill").appFont(.headline)
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(lastSevenDays, id: \.date) { item in
                        VStack(spacing: 7) {
                            Text(item.count == 0 ? "" : "\(item.count)")
                                .appFont(.caption2, weight: .bold)
                                .foregroundStyle(AppTheme.accent)
                                .frame(height: 14)
                            RoundedRectangle(cornerRadius: 7)
                                .fill(item.count == 0 ? Color.secondary.opacity(0.10) : AppTheme.accent.opacity(0.35 + min(Double(item.count), 3) * 0.18))
                                .frame(height: CGFloat(max(item.count, 1) * 18))
                            Text(item.date, format: .dateTime.weekday(.narrow))
                                .appFont(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.date.formatted(date: .complete, time: .omitted)): \(item.count) problems solved")
                    }
                }
                .frame(height: 100, alignment: .bottom)
            }
        }
    }

    private var difficultyCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Difficulty balance", systemImage: "chart.bar.xaxis").appFont(.headline)
                ForEach(ProblemDifficulty.allCases, id: \.self) { difficulty in
                    let total = Curriculum.allProblems.filter { $0.difficulty == difficulty }.count
                    let count = solved.filter { record in
                        Curriculum.problem(withID: record.problemID)?.difficulty == difficulty
                    }.count
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            DifficultyBadge(difficulty: difficulty)
                            Spacer()
                            Text("\(count) / \(total)").appFont(.caption, weight: .bold).foregroundStyle(.secondary)
                        }
                        ProgressView(value: Double(count), total: Double(max(total, 1)))
                            .tint(difficultyColor(difficulty))
                    }
                }
            }
        }
    }

    private var trackMastery: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Track mastery").appFont(.title3, weight: .bold).padding(.horizontal, 4)
            ForEach(Curriculum.allModules) { module in
                let count = module.problems.filter { plan.solvedIDs.contains($0.id) }.count
                LearningCard {
                    HStack(spacing: 12) {
                        LearningIcon(symbol: module.symbol)
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(module.title).appFont(.headline)
                                Spacer()
                                Text("\(count)/\(module.problems.count)")
                                    .appFont(.caption, weight: .bold)
                                    .foregroundStyle(count == module.problems.count ? .green : .secondary)
                            }
                            ProgressView(value: Double(count), total: Double(module.problems.count))
                                .tint(count == module.problems.count ? .green : AppTheme.accent)
                            Text(module.recognitionCues.first ?? module.summary)
                                .appFont(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private var learningSignals: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 13) {
                Label("Learning signals", systemImage: "waveform.path.ecg").appFont(.headline)
                HStack(spacing: 12) {
                    signal(value: "\(safeTotal(recognizedProgressRecords.map(\.attemptCount)))", label: "Test runs", symbol: "play.circle.fill")
                    signal(value: "\(safeTotal(recognizedProgressRecords.map(\.hintsRevealed)))", label: "Hints used", symbol: "lightbulb.fill")
                    signal(value: "\(solved.filter { $0.reviewLevel > 0 }.count)", label: "Reviewed", symbol: "brain.fill")
                }
                Text("Attempts and hints are feedback, not failure. The goal is to need less support when the pattern returns.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func signal(value: String, label: String, symbol: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: symbol).foregroundStyle(AppTheme.accent)
            Text(value).appFont(.title3, weight: .bold)
            Text(label).appFont(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .learningInset()
    }

    private func safeTotal(_ values: [Int]) -> Int {
        values.reduce(into: 0) { total, value in
            guard value > 0, total != Int.max else { return }
            let (sum, overflowed) = total.addingReportingOverflow(value)
            total = overflowed ? Int.max : sum
        }
    }

    private var lastSevenDays: [(date: Date, count: Int)] {
        (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { return nil }
            let count = solved.filter { record in
                guard let solvedAt = record.solvedAt else { return false }
                return calendar.isDate(solvedAt, inSameDayAs: date)
            }.count
            return (calendar.startOfDay(for: date), count)
        }
    }

    private func difficultyColor(_ difficulty: ProblemDifficulty) -> Color {
        switch difficulty {
        case .easy: .green
        case .medium: .orange
        case .hard: .pink
        }
    }
}
