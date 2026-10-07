import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppAppearance.darkModeEnabledKey) private var darkModeEnabled = false
    @StateObject private var nearbySync = NearbySyncService()
    @State private var selection = 0
    private let notificationService = NotificationService()

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                LearnHomeView(nearbySync: nearbySync)
            }
            .tabItem { Label("Today", systemImage: "sun.max") }
            .tag(0)

            NavigationStack {
                LearningPathView()
            }
            .tabItem { Label("Path", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }
            .tag(1)

            NavigationStack {
                ProgressDashboardView()
            }
            .tabItem { Label("Progress", systemImage: "chart.bar") }
            .tag(2)

            NavigationStack {
                LearningGuideView()
            }
            .tabItem { Label("Guide", systemImage: "books.vertical.fill") }
            .tag(3)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(4)
        }
        .tint(AppTheme.accent)
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
        .onAppear {
            nearbySync.configure(modelContext: modelContext)
            WidgetProgressExporter.refresh(context: modelContext)
            Task { await notificationService.reconcileProblemReminders(context: modelContext) }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                nearbySync.configure(modelContext: modelContext)
                nearbySync.resumeAdvertisingIfEnabled()
                WidgetProgressExporter.refresh(context: modelContext)
                Task { await notificationService.reconcileProblemReminders(context: modelContext) }
            } else if phase == .background {
                nearbySync.pause()
            }
        }
    }
}

struct NearbySyncCard: View {
    @ObservedObject var service: NearbySyncService

    var body: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    LearningIcon(symbol: "laptopcomputer.and.iphone")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nearby sync").appFont(.headline)
                        Text("Drafts, notes, learning progress, and streaks")
                            .appFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Label(service.status.title, systemImage: service.status.symbolName)
                    .appFont(.subheadline)
                    .foregroundStyle(statusColor)

                if service.status.isBusy {
                    ProgressView().progressViewStyle(.linear)
                }

                Text(instructions)
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)

                if let lastSyncDate = service.lastSyncDate {
                    Text("Last synced \(lastSyncDate, style: .relative)")
                        .appFont(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    service.enableAndSync()
                } label: {
                    Label(service.isEnabled ? "Sync nearby" : "Enable and sync", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(service.status.isBusy)

                if !service.pairedDeviceNames.isEmpty && !service.status.isBusy {
                    HStack {
                        Label(service.pairedDeviceNames.joined(separator: ", "), systemImage: "link")
                            .appFont(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Button("Forget", role: .destructive) { service.forgetPairedDevices() }
                            .appFont(.caption)
                    }
                }
            }
        }
        .alert("Pair nearby device?", isPresented: pairingIsPresented) {
            Button("Pair and sync") { service.approvePairing() }
            Button("Cancel", role: .cancel) { service.declinePairing() }
        } message: {
            if let request = service.pairingRequest {
                Text("Confirm that \(request.peerName) shows code \(request.code).")
            }
        }
    }

    private var pairingIsPresented: Binding<Bool> {
        Binding(get: { service.pairingRequest != nil }, set: { _ in })
    }

    private var instructions: String {
        if !service.isEnabled {
            return "Enable on both devices once, allow Local Network access, and confirm the matching code."
        }
        if service.pairedDeviceNames.isEmpty {
            return "Open CodeStreak on your other device and enable nearby sync there too."
        }
        return "Keep both apps open, then sync from either device. Newer edits win."
    }

    private var statusColor: Color {
        if case .failed = service.status { return .red }
        if case .synced = service.status { return .green }
        return .secondary
    }
}
