import SwiftData
import SwiftUI

@main
@MainActor
struct CodeStreakApp: App {
    private let modelContainer: ModelContainer?
    @StateObject private var textSizeController = AppTextSizeController()

    init() {
        do {
            let container = try ModelContainer(
                for: CompletionRecord.self,
                LearningProgressRecord.self
            )
            do {
                try CurriculumProgressMigrationService().migrate(context: container.mainContext)
            } catch {
#if DEBUG
                print("CodeStreak could not migrate the old repeated curriculum progress: \(error)")
#endif
            }
            modelContainer = container
        } catch {
            modelContainer = nil
#if DEBUG
            print("CodeStreak could not initialize SwiftData: \(error)")
#endif
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let modelContainer {
                    DashboardView()
                        .modelContainer(modelContainer)
                } else {
                    PersistenceUnavailableView()
                }
            }
            .environmentObject(textSizeController)
            .appTextSizing(textSizeController)
        }
#if os(macOS)
        .defaultSize(width: 760, height: 820)
        .commands {
            CommandGroup(after: .toolbar) {
                Divider()

                Button("Increase Text Size") {
                    textSizeController.increase()
                }
                .keyboardShortcut("+", modifiers: [.command])
                .disabled(!textSizeController.canIncrease)

                Button("Decrease Text Size") {
                    textSizeController.decrease()
                }
                .keyboardShortcut("-", modifiers: [.command])
                .disabled(!textSizeController.canDecrease)

                Button("Reset Text Size") {
                    textSizeController.reset()
                }
                .keyboardShortcut("0", modifiers: [.command])
                .disabled(!textSizeController.canReset)
            }
        }
#endif
    }
}

private struct PersistenceUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("CodeStreak couldn’t open", systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            Text("Your local history was not changed. Quit and reopen the app, or check that your device has free storage.")
        }
        .padding()
    }
}
