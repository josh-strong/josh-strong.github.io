import SwiftData
import SwiftUI

#if os(iOS)
import UIKit
#endif

struct LearnHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \CompletionRecord.completedAt, order: .reverse) private var completionRecords: [CompletionRecord]
    @Query private var progressRecords: [LearningProgressRecord]
    @AppStorage("dailyProblemGoal") private var dailyGoal = 1

    @ObservedObject var nearbySync: NearbySyncService
    @State private var now = Date()
    @State private var showingUndoConfirmation = false
    @State private var errorMessage: String?

    private let calendar = Calendar.autoupdatingCurrent
    private let completionService = CompletionService()
    private let calculator = StreakCalculator()
    private let planEngine = LearningPlanEngine()

    private var completedRecords: [CompletionRecord] { completionRecords.filter(\.isCompleted) }

    private var summary: StreakSummary {
        calculator.calculate(completedDates: completedRecords.map(\.completedAt), now: now, calendar: calendar)
    }

    private var plan: LearningPlanSnapshot {
        planEngine.snapshot(records: progressRecords, now: now)
    }

    private var solvedToday: Int {
        progressRecords.filter { record in
            guard Curriculum.problem(withID: record.problemID) != nil else { return false }
            guard let solvedAt = record.solvedAt else { return false }
            return calendar.isDate(solvedAt, inSameDayAs: now)
        }.count
    }

    private var missionProblem: AlgorithmProblem? {
        if let reviewID = plan.dueReviewIDs.first, let problem = Curriculum.problem(withID: reviewID) {
            return problem
        }
        guard let nextID = plan.nextProblemID ?? plan.nextMLProblemID else { return nil }
        return Curriculum.problem(withID: nextID)
    }

    private var missionIsReview: Bool {
        guard let missionProblem else { return false }
        return plan.dueReviewIDs.contains(missionProblem.id)
    }

    private var missionIsFlaggedReview: Bool {
        guard let missionProblem else { return false }
        return plan.flaggedReviewIDs.contains(missionProblem.id)
    }

    private var missionProgressRecord: LearningProgressRecord? {
        guard let missionProblem else { return nil }
        return progressRecords.first { $0.problemID == missionProblem.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                dailyGoalCard

                if let missionProblem {
                    NavigationLink(value: missionProblem) {
                        missionCard(problem: missionProblem)
                    }
                    .buttonStyle(.plain)
                } else {
                    completedPathCard
                }

                StreakSummaryView(summary: summary)
                habitCard
                RecentHistoryView(records: completedRecords, now: now, calendar: calendar)
                NearbySyncCard(service: nearbySync)

                NavigationLink {
                    HistoryView(records: completedRecords, now: now, calendar: calendar)
                } label: {
                    Label("Open practice calendar", systemImage: "calendar")
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .frame(maxWidth: 720, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Today")
        .learningBackground()
        .navigationDestination(for: AlgorithmProblem.self) { selectedProblem in
            ProblemWorkspaceFlowView(initialProblem: selectedProblem)
                .id(selectedProblem.id)
        }
        .confirmationDialog("Undo today’s practice?", isPresented: $showingUndoConfirmation) {
            Button("Undo practice", role: .destructive) { undoToday() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Solved-problem progress is kept; only the daily streak marker is removed.")
        }
        .alert("Couldn’t update progress", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
        .onAppear { now = Date() }
        .task { await refreshAfterMidnight() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(now, format: .dateTime.weekday(.wide).day().month(.wide))
                .appFont(.subheadline, weight: .medium)
                .foregroundStyle(.secondary)
            Text(greeting)
                .appFont(.largeTitle, weight: .bold)
                .tracking(-0.7)
            Text("One focused problem at a time. Learn the pattern, explain it, then retrieve it later.")
                .appFont(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var dailyGoalCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Daily target").appFont(.headline)
                        Text("\(solvedToday) of \(dailyGoal) new problem\(dailyGoal == 1 ? "" : "s")")
                            .appFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(solvedToday >= dailyGoal ? "Done" : "\(max(dailyGoal - solvedToday, 0)) left")
                        .appFont(.subheadline, weight: .bold)
                        .foregroundStyle(solvedToday >= dailyGoal ? .green : AppTheme.accent)
                }
                ProgressView(value: min(Double(solvedToday) / Double(max(dailyGoal, 1)), 1))
                    .tint(solvedToday >= dailyGoal ? .green : AppTheme.accent)
            }
        }
    }

    private func missionCard(problem: AlgorithmProblem) -> some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 12) {
                    LearningIcon(
                        symbol: missionIsFlaggedReview ? "flag.fill" : (missionIsReview ? "brain.fill" : "play.fill"),
                        colors: [missionIsFlaggedReview ? .orange : (missionIsReview ? .purple : AppTheme.accent)]
                    )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(missionIsFlaggedReview ? "Flagged revisit" : (missionIsReview ? "Retrieval review" : "Next on your path"))
                            .appFont(.caption, weight: .bold)
                            .foregroundStyle(missionIsFlaggedReview ? Color.orange : Color.secondary)
                        Text(problem.title).appFont(.title3, weight: .bold)
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .appFont(.title2)
                        .foregroundStyle(AppTheme.accent)
                }

                Text(problem.whyItMatters)
                    .appFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                if missionIsFlaggedReview {
                    let reminderNote = missionProgressRecord?.notes
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    Label {
                        Text(reminderNote.isEmpty
                             ? "You marked this as difficult or worth remembering. Reconstruct the idea before looking at your old solution."
                             : reminderNote)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "note.text")
                    }
                    .appFont(.footnote, weight: reminderNote.isEmpty ? .regular : .medium)
                    .foregroundStyle(reminderNote.isEmpty ? Color.secondary : Color.primary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                HStack(spacing: 10) {
                    DifficultyBadge(difficulty: problem.difficulty)
                    if let module = Curriculum.module(containing: problem.id) {
                        Label(module.title, systemImage: module.symbol)
                    }
                    Label("\(problem.estimatedMinutes) min", systemImage: "clock")
                }
                .appFont(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var completedPathCard: some View {
        LearningCard {
            ContentUnavailableView(
                "Curriculum complete",
                systemImage: "trophy.fill",
                description: Text("Keep strengthening recall through scheduled reviews.")
            )
        }
    }

    private var habitCard: some View {
        LearningCard {
            VStack(spacing: 12) {
                CompletionButton(isCompleted: summary.isCompletedToday) { completeToday() }
                if summary.isCompletedToday {
                    Text("Solving any problem marks practice automatically.")
                        .appFont(.caption)
                        .foregroundStyle(.secondary)
                    Button("Undo today’s practice", role: .destructive) { showingUndoConfirmation = true }
                        .frame(minHeight: 44)
                }
            }
        }
    }

    private var greeting: String {
        let hour = calendar.component(.hour, from: now)
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func completeToday() {
        do {
            try completionService.markCompleted(on: now, context: modelContext, calendar: calendar)
#if os(iOS)
            if !reduceMotion { UINotificationFeedbackGenerator().notificationOccurred(.success) }
#endif
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func undoToday() {
        do {
            try completionService.removeCompletion(on: now, context: modelContext, calendar: calendar)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func refreshAfterMidnight() async {
        while !Task.isCancelled {
            let reference = Date()
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: reference)) else { return }
            do {
                try await Task.sleep(for: .seconds(max(tomorrow.timeIntervalSince(reference) + 1, 1)))
            } catch {
                return
            }
            now = Date()
        }
    }
}
