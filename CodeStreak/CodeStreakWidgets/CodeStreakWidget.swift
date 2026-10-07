import SwiftUI
import WidgetKit

struct CodeStreakWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetProgressSnapshot
}

struct CodeStreakWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CodeStreakWidgetEntry {
        CodeStreakWidgetEntry(
            date: .now,
            snapshot: WidgetProgressSnapshot(
                solvedCount: 84,
                totalCount: 174,
                currentStreak: 12,
                latestCompletionAt: .now,
                dueReviewCount: 2,
                nextProblemTitle: "Maximum Circular Subarray",
                updatedAt: .now
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CodeStreakWidgetEntry) -> Void) {
        completion(CodeStreakWidgetEntry(date: .now, snapshot: WidgetProgressSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CodeStreakWidgetEntry>) -> Void) {
        let now = Date()
        let entry = CodeStreakWidgetEntry(date: now, snapshot: WidgetProgressSnapshot.load())
        let calendar = Calendar.autoupdatingCurrent
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now.addingTimeInterval(21_600)
        completion(Timeline(entries: [entry], policy: .after(tomorrow.addingTimeInterval(1))))
    }
}

struct CodeStreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CodeStreakWidgetEntry

    private var completedToday: Bool {
        entry.snapshot.isCompletedToday(at: entry.date)
    }

    private var streak: Int {
        entry.snapshot.displayedStreak(at: entry.date)
    }

    private var nextStreakDay: Int {
        completedToday ? max(streak, 1) : max(streak + 1, 1)
    }

    private var progressPercent: Int {
        Int((entry.snapshot.progress * 100).rounded())
    }

    private var milestone: Int {
        guard entry.snapshot.totalCount > 0 else { return 0 }
        guard entry.snapshot.solvedCount < entry.snapshot.totalCount else {
            return entry.snapshot.totalCount
        }
        let next = ((entry.snapshot.solvedCount / 25) + 1) * 25
        return min(next, entry.snapshot.totalCount)
    }

    private var milestoneMessage: String {
        if entry.snapshot.solvedCount >= entry.snapshot.totalCount {
            return "Curriculum complete"
        }
        let remaining = max(milestone - entry.snapshot.solvedCount, 0)
        return "\(remaining) to the \(milestone) milestone"
    }

    private var actionTitle: String {
        if completedToday {
            return "Momentum secured"
        }
        if entry.snapshot.dueReviewCount > 0 {
            let suffix = entry.snapshot.dueReviewCount == 1 ? "" : "s"
            return "Start \(entry.snapshot.dueReviewCount) review\(suffix)"
        }
        return "Solve today's problem"
    }

    private var supportingTitle: String {
        if completedToday {
            return streak <= 1 ? "Day one is in the bank." : "\(streak) days strong. Keep compounding."
        }
        if streak == 0 {
            return "A streak starts with one focused problem."
        }
        return "One session keeps \(streak) days of momentum alive."
    }

    private var accent: Color {
        completedToday ? Color(red: 0.38, green: 0.94, blue: 0.72) : Color(red: 1.00, green: 0.67, blue: 0.26)
    }

    var body: some View {
        Group {
            switch family {
#if os(iOS)
            case .accessoryInline:
                inlineView
            case .accessoryCircular:
                circularView
            case .accessoryRectangular:
                rectangularView
#endif
            case .systemMedium:
                mediumView
            default:
                smallView
            }
        }
        .containerBackground(for: .widget) {
            homeBackground
        }
    }

    private var homeBackground: some View {
        ZStack {
            LinearGradient(
                colors: completedToday
                    ? [Color(red: 0.035, green: 0.20, blue: 0.19), Color(red: 0.10, green: 0.13, blue: 0.30)]
                    : [Color(red: 0.09, green: 0.10, blue: 0.25), Color(red: 0.28, green: 0.10, blue: 0.33)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(accent.opacity(0.19))
                .frame(width: 180, height: 180)
                .blur(radius: 10)
                .offset(x: 105, y: -90)

            Circle()
                .strokeBorder(.white.opacity(0.07), lineWidth: 1)
                .frame(width: 130, height: 130)
                .offset(x: 90, y: -70)

            Text("{ }")
                .font(.system(size: 54, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.035))
                .rotationEffect(.degrees(-8))
                .offset(x: 92, y: 64)
        }
    }

#if os(iOS)
    private var inlineView: some View {
        Label(
            completedToday ? "Momentum kept · \(streak) day streak" : "Make it day \(nextStreakDay) · practice now",
            systemImage: completedToday ? "checkmark.circle.fill" : "flame.fill"
        )
    }

    private var circularView: some View {
        Gauge(value: entry.snapshot.progress) {
            Text("Progress")
        } currentValueLabel: {
            VStack(spacing: -2) {
                Image(systemName: completedToday ? "checkmark" : "flame.fill")
                    .font(.caption.bold())
                Text("\(streak)")
                    .font(.system(.body, design: .rounded, weight: .heavy))
            }
            .widgetAccentable()
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Image(systemName: completedToday ? "checkmark.seal.fill" : "flame.fill")
                Text(completedToday ? "\(streak) days strong" : "Make it day \(nextStreakDay)")
                    .font(.headline)
                Spacer(minLength: 0)
            }

            Text(actionTitle)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            ProgressView(value: entry.snapshot.progress)
                .widgetAccentable()

            Text("\(entry.snapshot.solvedCount) solved · \(progressPercent)%")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
#endif

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "terminal.fill")
                    .font(.caption.bold())
                    .foregroundStyle(accent)
                Text("CODESTREAK")
                    .font(.caption2.bold())
                    .tracking(0.7)
                    .foregroundStyle(.white.opacity(0.82))
                Spacer()
                StreakCapsule(streak: streak, accent: accent)
            }

            Spacer(minLength: 0)

            Text(completedToday ? "Momentum\nsecured." : (streak == 0 ? "Start your\nfirst streak." : "Make it\nday \(nextStreakDay)."))
                .font(.system(size: 23, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.82)
                .lineSpacing(-2)

            HStack(spacing: 6) {
                Image(systemName: completedToday ? "checkmark.circle.fill" : "play.fill")
                    .foregroundStyle(accent)
                Text(actionTitle)
                    .font(.caption.bold())
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.55))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(.white.opacity(0.09), in: Capsule())
            .overlay {
                Capsule().strokeBorder(.white.opacity(0.09))
            }

            ProgressView(value: entry.snapshot.progress)
                .tint(accent)
                .scaleEffect(x: 1, y: 0.75)
        }
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: "terminal.fill")
                    .foregroundStyle(accent)
                Text("CODESTREAK")
                    .font(.caption.bold())
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.82))
                Spacer()
                StreakCapsule(streak: streak, accent: accent)
            }

            HStack(spacing: 14) {
                MomentumRing(
                    progress: entry.snapshot.progress,
                    completedToday: completedToday,
                    accent: accent
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(completedToday ? "Today's momentum is safe" : (streak == 0 ? "Start with one problem" : "Protect your momentum"))
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(supportingTitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Image(systemName: completedToday ? "checkmark.circle.fill" : "play.fill")
                            .foregroundStyle(accent)
                        Text(actionTitle)
                            .font(.caption.bold())
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.09), in: Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(milestoneMessage)
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.72))
                    Spacer()
                    Text("\(entry.snapshot.solvedCount) solved · \(progressPercent)%")
                        .font(.caption2.bold())
                        .foregroundStyle(accent)
                }
                ProgressView(value: entry.snapshot.progress)
                    .tint(accent)
                    .scaleEffect(x: 1, y: 0.75)
            }
        }
    }
}

private struct StreakCapsule: View {
    let streak: Int
    let accent: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(accent)
            Text("\(streak)")
                .foregroundStyle(.white)
        }
        .font(.caption.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.white.opacity(0.09), in: Capsule())
        .overlay {
            Capsule().strokeBorder(.white.opacity(0.09))
        }
    }
}

private struct MomentumRing: View {
    let progress: Double
    let completedToday: Bool
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.11), lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(accent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .fill(.white.opacity(0.065))
                .padding(11)
            Image(systemName: completedToday ? "checkmark" : "flame.fill")
                .font(.system(size: 23, weight: .heavy))
                .foregroundStyle(accent)
        }
        .frame(width: 72, height: 72)
    }
}

@main
struct CodeStreakProgressWidget: Widget {
    private var supportedFamilies: [WidgetFamily] {
#if os(iOS)
        [.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular]
#else
        [.systemSmall, .systemMedium]
#endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetProgressSnapshot.widgetKind, provider: CodeStreakWidgetProvider()) { entry in
            CodeStreakWidgetView(entry: entry)
        }
        .configurationDisplayName("CodeStreak Progress")
        .description("Protect today’s momentum, grow your streak, and reach the next curriculum milestone.")
        .supportedFamilies(supportedFamilies)
    }
}
