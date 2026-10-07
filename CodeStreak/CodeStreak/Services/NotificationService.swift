import Foundation
import SwiftData
import UserNotifications

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum NotificationServiceError: LocalizedError {
    case permissionDenied
    case settingsUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notifications are disabled for CodeStreak. You can enable them in System Settings."
        case .settingsUnavailable:
            return "System notification settings could not be opened."
        }
    }
}

@MainActor
struct NotificationService {
    private let center = UNUserNotificationCenter.current()

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func enableDailyReminder(hour: Int, minute: Int) async throws {
        try Task.checkCancellation()
        var status = await authorizationStatus()
        try Task.checkCancellation()
        if status == .notDetermined {
            let granted = try await center.requestAuthorization(options: [.alert])
            guard granted else { throw NotificationServiceError.permissionDenied }
            try Task.checkCancellation()
            status = await authorizationStatus()
        }

        try Task.checkCancellation()
        guard status == .authorized || status == .provisional else {
            throw NotificationServiceError.permissionDenied
        }

        center.removePendingNotificationRequests(
            withIdentifiers: [AppConstants.dailyReminderIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = AppConstants.reminderTitle
        content.body = AppConstants.reminderBody
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute),
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: AppConstants.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        do {
            try await center.add(request)
            try Task.checkCancellation()
        } catch is CancellationError {
            // A newer toggle/time selection superseded this request while the
            // notification centre call was suspended. Do not leave the older
            // reminder scheduled behind the current UI state.
            center.removePendingNotificationRequests(
                withIdentifiers: [AppConstants.dailyReminderIdentifier]
            )
            throw CancellationError()
        }
    }

    @discardableResult
    func scheduleProblemReminder(
        problemID: String,
        title: String,
        notes: String,
        at date: Date,
        requestAuthorization: Bool = true
    ) async throws -> Bool {
        try Task.checkCancellation()
        var status = await authorizationStatus()
        if status == .notDetermined, requestAuthorization {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            guard granted else { throw NotificationServiceError.permissionDenied }
            status = await authorizationStatus()
        }
        guard status == .authorized || status == .provisional else {
            if requestAuthorization { throw NotificationServiceError.permissionDenied }
            return false
        }

        let identifier = problemReminderIdentifier(for: problemID)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = UNMutableNotificationContent()
        content.title = "Revisit: \(title)"
        content.body = trimmedNotes.isEmpty
            ? "You flagged this problem as difficult or worth remembering. Review your approach while it is still fresh."
            : String(trimmedNotes.prefix(220))
        content.sound = .default
        content.userInfo = ["problemID": problemID]

        let delay = max(date.timeIntervalSinceNow, 60)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        )
        do {
            try await center.add(request)
            try Task.checkCancellation()
            return true
        } catch is CancellationError {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            throw CancellationError()
        }
    }

    func cancelProblemReminder(problemID: String) {
        let identifier = problemReminderIdentifier(for: problemID)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    /// Keeps device-local alerts aligned with the synced SwiftData state.
    /// This never prompts: permission is requested only when the user flags a
    /// problem or explicitly enables reminders in Settings.
    func reconcileProblemReminders(
        context: ModelContext,
        now: Date = .now
    ) async {
        guard let records = try? context.fetch(FetchDescriptor<LearningProgressRecord>()) else {
            return
        }

        for record in records {
            guard let problem = Curriculum.problem(withID: record.problemID) else {
                cancelProblemReminder(problemID: record.problemID)
                continue
            }
            guard record.isFlaggedForReview else {
                cancelProblemReminder(problemID: record.problemID)
                continue
            }
            guard let reviewAt = record.flaggedReviewAt,
                  reviewAt.timeIntervalSince(now) > 60 else {
                // A due flag is surfaced at the top of Today. Do not replace
                // an already delivered alert with a delayed one-minute alert.
                continue
            }
            _ = try? await scheduleProblemReminder(
                problemID: problem.id,
                title: problem.title,
                notes: record.notes,
                at: reviewAt,
                requestAuthorization: false
            )
        }
    }

    func disableDailyReminder() {
        center.removePendingNotificationRequests(
            withIdentifiers: [AppConstants.dailyReminderIdentifier]
        )
    }

    func openSystemSettings() throws {
#if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            throw NotificationServiceError.settingsUnavailable
        }
        UIApplication.shared.open(url)
#elseif os(macOS)
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") else {
            throw NotificationServiceError.settingsUnavailable
        }
        NSWorkspace.shared.open(url)
#endif
    }

    private func problemReminderIdentifier(for problemID: String) -> String {
        "codestreak.problem-review.\(problemID)"
    }
}
