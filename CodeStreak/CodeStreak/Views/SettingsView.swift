import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var textSizeController: AppTextSizeController
    @AppStorage(AppAppearance.darkModeEnabledKey) private var darkModeEnabled = false
    @AppStorage(ReminderSettings.enabledKey) private var remindersEnabled = false
    @AppStorage(ReminderSettings.hourKey) private var reminderHour = ReminderSettings.defaultHour
    @AppStorage(ReminderSettings.minuteKey) private var reminderMinute = ReminderSettings.defaultMinute
    @AppStorage("dailyProblemGoal") private var dailyProblemGoal = 1

    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var errorMessage: String?
    @State private var reminderUpdateTask: Task<Void, Never>?

    private let notificationService = NotificationService()
    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle(isOn: $darkModeEnabled) {
                    Label(
                        darkModeEnabled ? "Dark mode" : "Light mode",
                        systemImage: darkModeEnabled ? "moon.fill" : "sun.max.fill"
                    )
                }
                .tint(AppTheme.accent)

                LabeledContent("Text size", value: textSizeController.displayName)

                HStack(spacing: 10) {
                    Button {
                        textSizeController.decrease()
                    } label: {
                        Label("Smaller", systemImage: "textformat.size.smaller")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!textSizeController.canDecrease)

                    Button("Reset") {
                        textSizeController.reset()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!textSizeController.canReset)

                    Button {
                        textSizeController.increase()
                    } label: {
                        Label("Larger", systemImage: "textformat.size.larger")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!textSizeController.canIncrease)
                }

                Text("Appearance choices apply immediately and are remembered on this device. On Mac, use ⌘+ and ⌘− to resize text, or ⌘0 to reset it.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Learning plan") {
                Picker("Daily new-problem target", selection: $dailyProblemGoal) {
                    Text("1 problem").tag(1)
                    Text("2 problems").tag(2)
                }

                LabeledContent(
                    "Curriculum",
                    value: "\(Curriculum.allProblems.count) distinct problems · 2 parallel tracks"
                )
                LabeledContent("Execution", value: "Python 3 · on device")

                Text("The path unlocks one new problem at a time. Scheduled reviews take priority on Today so patterns are retrieved before they are forgotten.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }

#if os(iOS)
            Section("Home & Lock Screen") {
                Label("CodeStreak progress widgets", systemImage: "rectangle.3.group.bubble.left.fill")
                Text("Add a widget to see whether today is complete, your streak, solved total, reviews, and the next problem without opening CodeStreak.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)

                LabeledContent("Home Screen", value: "Small or medium")
                LabeledContent("Lock Screen", value: "Inline, circle, or rectangle")
            }
#endif

            Section("Daily reminder") {
                Toggle("Daily reminder", isOn: $remindersEnabled)
                    .tint(AppTheme.accent)
                    .onChange(of: remindersEnabled) { _, enabled in
                        scheduleReminderUpdate(enabled: enabled)
                    }

                DatePicker(
                    "Reminder time",
                    selection: reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .disabled(!remindersEnabled)

                LabeledContent("Authorization", value: authorizationDescription)

                if authorizationStatus == .denied {
                    Text("Notifications are denied. Enable them in System Settings if you want a daily reminder.")
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Open System Settings") {
                        do {
                            try notificationService.openSystemSettings()
                        } catch {
                            report(error)
                        }
                    }
                }

                Text("Permission is requested only when you turn reminders on. The selected time stays saved when reminders are off.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("About your data") {
                Label("Your code and notes stay on your devices", systemImage: "lock.shield")
                Text("CodeStreak has no account, analytics, advertising, or internet service. Python solutions run inside the bundled offline learning runtime. Nearby sync talks directly to a paired device while both apps are open.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .learningBackground()
        .task {
            authorizationStatus = await notificationService.authorizationStatus()
        }
        .alert("Reminder couldn’t be updated", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var reminderTime: Binding<Date> {
        Binding {
            calendar.date(
                from: DateComponents(hour: reminderHour, minute: reminderMinute)
            ) ?? Date()
        } set: { newValue in
            let components = calendar.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? ReminderSettings.defaultHour
            reminderMinute = components.minute ?? ReminderSettings.defaultMinute
            if remindersEnabled {
                scheduleReminderUpdate(enabled: true)
            }
        }
    }

    private func scheduleReminderUpdate(enabled: Bool) {
        let previousTask = reminderUpdateTask
        previousTask?.cancel()
        reminderUpdateTask = Task { @MainActor in
            // Serialize updates so a cancelled request cannot remove a newer
            // notification that happens to use the same identifier.
            await previousTask?.value
            guard !Task.isCancelled else { return }
            await updateReminder(enabled: enabled)
        }
    }

    private var authorizationDescription: String {
        switch authorizationStatus {
        case .notDetermined: "Not requested"
        case .denied: "Denied"
        case .authorized: "Allowed"
        case .provisional: "Provisional"
        case .ephemeral: "Temporary"
        @unknown default: "Unknown"
        }
    }

    @MainActor
    private func updateReminder(enabled: Bool) async {
        if !enabled {
            notificationService.disableDailyReminder()
            authorizationStatus = await notificationService.authorizationStatus()
            return
        }

        do {
            try await notificationService.enableDailyReminder(
                hour: reminderHour,
                minute: reminderMinute
            )
            await notificationService.reconcileProblemReminders(context: modelContext)
            authorizationStatus = await notificationService.authorizationStatus()
        } catch is CancellationError {
            return
        } catch {
            remindersEnabled = false
            authorizationStatus = await notificationService.authorizationStatus()
            report(error)
        }
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func report(_ error: Error) {
#if DEBUG
        print("CodeStreak notification error: \(error)")
#endif
        errorMessage = error.localizedDescription
    }
}
