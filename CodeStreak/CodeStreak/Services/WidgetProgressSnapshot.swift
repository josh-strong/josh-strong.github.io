import Foundation

struct WidgetProgressSnapshot: Codable, Equatable, Sendable {
    static let appGroupIdentifier = "group.com.jstrong.CodeStreak"
    static let storageKey = "widgetProgressSnapshot.v1"
    static let widgetKind = "CodeStreakProgressWidget"

    let solvedCount: Int
    let totalCount: Int
    let currentStreak: Int
    let latestCompletionAt: Date?
    let dueReviewCount: Int
    let nextProblemTitle: String?
    let updatedAt: Date

    static let empty = WidgetProgressSnapshot(
        solvedCount: 0,
        totalCount: 174,
        currentStreak: 0,
        latestCompletionAt: nil,
        dueReviewCount: 0,
        nextProblemTitle: "Positive Total",
        updatedAt: .distantPast
    )

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return min(max(Double(solvedCount) / Double(totalCount), 0), 1)
    }

    func isCompletedToday(at date: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard let latestCompletionAt else { return false }
        return calendar.isDate(latestCompletionAt, inSameDayAs: date)
    }

    func displayedStreak(at date: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> Int {
        guard let latestCompletionAt else { return 0 }
        let latestDay = calendar.startOfDay(for: latestCompletionAt)
        let today = calendar.startOfDay(for: date)
        let dayGap = calendar.dateComponents([.day], from: latestDay, to: today).day ?? 0
        return (0...1).contains(dayGap) ? max(currentStreak, 0) : 0
    }

    static func load() -> WidgetProgressSnapshot {
        guard
            let data = sharedDefaults.data(forKey: storageKey),
            let snapshot = try? JSONDecoder().decode(WidgetProgressSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        Self.sharedDefaults.set(data, forKey: Self.storageKey)
    }

    private static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
}
