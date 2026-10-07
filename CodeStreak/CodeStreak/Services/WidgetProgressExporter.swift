import Foundation
import SwiftData

#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
enum WidgetProgressExporter {
    static func refresh(context: ModelContext, now: Date = .now) {
        do {
            let completionRecords = try context.fetch(FetchDescriptor<CompletionRecord>())
            let progressRecords = try context.fetch(FetchDescriptor<LearningProgressRecord>())
            let completedDates = completionRecords
                .filter(\.isCompleted)
                .map(\.completedAt)
            let calendar = Calendar.autoupdatingCurrent
            let eligibleCompletionDates = completedDates.filter {
                calendar.compare($0, to: now, toGranularity: .day) != .orderedDescending
            }
            let summary = StreakCalculator().calculate(
                completedDates: completedDates,
                now: now,
                calendar: calendar
            )
            let plan = LearningPlanEngine().snapshot(records: progressRecords, now: now)
            let nextTitle = (plan.nextProblemID ?? plan.nextMLProblemID)
                .flatMap { Curriculum.problem(withID: $0)?.title }

            WidgetProgressSnapshot(
                solvedCount: plan.solvedCount,
                totalCount: Curriculum.allProblems.count,
                currentStreak: summary.currentStreak,
                latestCompletionAt: eligibleCompletionDates.max(),
                dueReviewCount: plan.dueReviewIDs.count,
                nextProblemTitle: nextTitle,
                updatedAt: now
            ).save()

#if canImport(WidgetKit)
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetProgressSnapshot.widgetKind)
#endif
        } catch {
#if DEBUG
            print("CodeStreak could not refresh its widget snapshot: \(error)")
#endif
        }
    }
}
