import Foundation
import SwiftData
@preconcurrency import Combine
@preconcurrency import MultipeerConnectivity

#if os(iOS)
import UIKit
#endif

enum NearbySyncStatus: Equatable {
    case disabled
    case idle
    case searching
    case waitingForPeerApproval(peerName: String, code: String)
    case awaitingPairingApproval(peerName: String)
    case connecting(peerName: String)
    case syncing(peerName: String)
    case synced(peerName: String, changes: Int)
    case failed(message: String)

    var isBusy: Bool {
        switch self {
        case .searching, .waitingForPeerApproval, .awaitingPairingApproval, .connecting, .syncing:
            true
        default:
            false
        }
    }

    var title: String {
        switch self {
        case .disabled: "Nearby sync is off"
        case .idle: "Ready to sync"
        case .searching: "Looking for your other device…"
        case let .waitingForPeerApproval(peerName, code):
            "On \(peerName), confirm code \(code)"
        case let .awaitingPairingApproval(peerName): "Pairing with \(peerName)…"
        case let .connecting(peerName): "Connecting to \(peerName)…"
        case let .syncing(peerName): "Syncing with \(peerName)…"
        case let .synced(peerName, changes):
            changes == 0 ? "Up to date with \(peerName)" : "Synced \(changes) change\(changes == 1 ? "" : "s") with \(peerName)"
        case let .failed(message): message
        }
    }

    var symbolName: String {
        switch self {
        case .disabled: "arrow.triangle.2.circlepath"
        case .idle: "checkmark.circle"
        case .searching, .connecting, .syncing: "arrow.triangle.2.circlepath"
        case .waitingForPeerApproval, .awaitingPairingApproval: "number.circle"
        case .synced: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        }
    }
}

struct NearbyPairingRequest: Identifiable, Equatable {
    let deviceID: String
    let peerName: String
    let code: String

    var id: String { deviceID }
}

@MainActor
final class NearbySyncService: NSObject, ObservableObject {
    @Published private(set) var status: NearbySyncStatus
    @Published private(set) var pairingRequest: NearbyPairingRequest?
    @Published private(set) var isEnabled: Bool
    @Published private(set) var pairedDeviceNames: [String]
    @Published private(set) var lastSyncDate: Date?

    private static let serviceType = "codestreak-sync"
    private static let enabledKey = "nearbySyncEnabled"
    private static let pairedDevicesKey = "nearbySyncPairedDevices"
    private static let lastSyncKey = "nearbySyncLastDate"

    private let localDeviceID: String
    private let localDeviceName: String
    private let peerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private var modelContext: ModelContext?
    private var pairedDevices: [String: PairedDevice]
    private var isAdvertising = false
    private var timeoutTask: Task<Void, Never>?
    private var pendingInvitationHandler: UncheckedSendableBox<(Bool, MCSession?) -> Void>?
    private var pendingOutgoingDeviceID: String?
    private var pendingOutgoingName: String?
    private var currentRemoteDeviceID: String?
    private var currentRemoteName: String?
    private var hasReceivedEnvelope = false
    private var hasReceivedAcknowledgement = false
    private var localMergeChangeCount = 0
    private var remoteMergeChangeCount = 0

    override init() {
        let defaults = UserDefaults.standard
        let localDeviceID = DeviceIdentity.id
        let localDeviceName = Self.deviceName
        let peerDisplayName = Self.peerDisplayName(from: localDeviceName)
        let peerID = MCPeerID(displayName: peerDisplayName)

        self.localDeviceID = localDeviceID
        self.localDeviceName = localDeviceName
        self.peerID = peerID
        session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: [
                "deviceID": localDeviceID,
                "deviceName": peerDisplayName
            ],
            serviceType: Self.serviceType
        )
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)

        let enabled = defaults.bool(forKey: Self.enabledKey)
        isEnabled = enabled
        status = enabled ? .idle : .disabled
        pairedDevices = Self.loadPairedDevices(defaults: defaults)
        pairedDeviceNames = pairedDevices.values.map(\.name).sorted()
        lastSyncDate = defaults.object(forKey: Self.lastSyncKey) as? Date

        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self

        if enabled {
            startAdvertising()
        }
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func enableAndSync() {
        if !isEnabled {
            isEnabled = true
            UserDefaults.standard.set(true, forKey: Self.enabledKey)
            startAdvertising()
        }
        syncNearby()
    }

    func syncNearby() {
        guard !status.isBusy else { return }
        guard modelContext != nil else {
            status = .failed(message: "Local history isn’t ready yet. Please try again.")
            return
        }

        startAdvertising()
        resetExchangeState()
        status = .searching
        browser.startBrowsingForPeers()
        scheduleTimeout(seconds: 15, message: "No nearby CodeStreak device was found. Open the app on your other device and try again.")
    }

    func approvePairing() {
        guard
            let request = pairingRequest,
            let invitationHandler = pendingInvitationHandler
        else {
            return
        }

        remember(deviceID: request.deviceID, name: request.peerName)
        currentRemoteDeviceID = request.deviceID
        currentRemoteName = request.peerName
        pairingRequest = nil
        pendingInvitationHandler = nil
        status = .connecting(peerName: request.peerName)
        invitationHandler.value(true, session)
        scheduleTimeout(seconds: 20, message: "Couldn’t finish connecting to \(request.peerName). Please try again.")
    }

    func declinePairing() {
        pendingInvitationHandler?.value(false, nil)
        pendingInvitationHandler = nil
        pairingRequest = nil
        timeoutTask?.cancel()
        status = .idle
    }

    func forgetPairedDevices() {
        guard !status.isBusy else { return }
        pairedDevices.removeAll()
        persistPairedDevices()
        pairedDeviceNames = []
        status = .idle
    }

    func resumeAdvertisingIfEnabled() {
        if isEnabled {
            startAdvertising()
        }
    }

    func pause() {
        timeoutTask?.cancel()
        browser.stopBrowsingForPeers()
        session.disconnect()
        advertiser.stopAdvertisingPeer()
        isAdvertising = false
        cancelPendingInvitation()
        resetExchangeFlags()
        if status.isBusy {
            status = .idle
        }
    }

    private func startAdvertising() {
        guard isEnabled, !isAdvertising else { return }
        advertiser.startAdvertisingPeer()
        isAdvertising = true
    }

    private func foundPeer(
        _ peer: MCPeerID,
        discoveryInfo: [String: String]?
    ) {
        guard case .searching = status else { return }
        guard
            let remoteDeviceID = discoveryInfo?["deviceID"],
            remoteDeviceID != localDeviceID
        else {
            return
        }

        if !pairedDevices.isEmpty && pairedDevices[remoteDeviceID] == nil {
            return
        }

        let remoteName = discoveryInfo?["deviceName"] ?? peer.displayName
        timeoutTask?.cancel()
        browser.stopBrowsingForPeers()
        pendingOutgoingDeviceID = remoteDeviceID
        pendingOutgoingName = remoteName
        currentRemoteDeviceID = remoteDeviceID
        currentRemoteName = remoteName
        resetExchangeFlags()

        let code: String?
        if pairedDevices[remoteDeviceID] == nil {
            let generatedCode = String(format: "%06d", Int.random(in: 0...999_999))
            code = generatedCode
            status = .waitingForPeerApproval(peerName: remoteName, code: generatedCode)
        } else {
            code = nil
            status = .connecting(peerName: remoteName)
        }

        let invitation = SyncInvitation(
            senderDeviceID: localDeviceID,
            senderName: localDeviceName,
            pairingCode: code
        )

        do {
            let context = try JSONEncoder().encode(invitation)
            browser.invitePeer(peer, to: session, withContext: context, timeout: 20)
            scheduleTimeout(seconds: 25, message: "\(remoteName) didn’t finish connecting. Please try again.")
        } catch {
            fail("Couldn’t prepare the secure pairing request.", error: error)
        }
    }

    private func receivedInvitation(
        from peerName: String,
        context: Data?,
        invitationHandler: UncheckedSendableBox<(Bool, MCSession?) -> Void>
    ) {
        guard
            let context,
            let invitation = try? JSONDecoder().decode(SyncInvitation.self, from: context),
            invitation.version == SyncInvitation.currentVersion,
            invitation.senderDeviceID != localDeviceID
        else {
            invitationHandler.value(false, nil)
            return
        }

        var replacedSimultaneousOutgoingInvitation = false

        // If both devices tapped Sync simultaneously, deterministically keep one invitation.
        if pendingOutgoingDeviceID == invitation.senderDeviceID {
            if localDeviceID < invitation.senderDeviceID {
                invitationHandler.value(false, nil)
                return
            }
            browser.stopBrowsingForPeers()
            pendingOutgoingDeviceID = nil
            pendingOutgoingName = nil
            replacedSimultaneousOutgoingInvitation = true
        }

        let isAlreadyExchanging: Bool
        switch status {
        case .waitingForPeerApproval, .awaitingPairingApproval, .connecting, .syncing:
            isAlreadyExchanging = true
        default:
            isAlreadyExchanging = false
        }
        guard !isAlreadyExchanging || replacedSimultaneousOutgoingInvitation else {
            invitationHandler.value(false, nil)
            return
        }
        guard session.connectedPeers.isEmpty else {
            invitationHandler.value(false, nil)
            return
        }

        timeoutTask?.cancel()
        browser.stopBrowsingForPeers()
        resetExchangeFlags()
        currentRemoteDeviceID = invitation.senderDeviceID
        currentRemoteName = invitation.senderName.isEmpty ? peerName : invitation.senderName

        if pairedDevices[invitation.senderDeviceID] != nil {
            status = .connecting(peerName: currentRemoteName ?? peerName)
            invitationHandler.value(true, session)
            scheduleTimeout(seconds: 20, message: "Couldn’t connect to \(currentRemoteName ?? peerName). Please try again.")
            return
        }

        guard let code = invitation.pairingCode else {
            invitationHandler.value(false, nil)
            status = .failed(message: "The nearby device needs to be paired again.")
            return
        }

        pendingInvitationHandler = invitationHandler
        pairingRequest = NearbyPairingRequest(
            deviceID: invitation.senderDeviceID,
            peerName: currentRemoteName ?? peerName,
            code: code
        )
        status = .awaitingPairingApproval(peerName: currentRemoteName ?? peerName)
    }

    private func peerStateChanged(peerName: String, stateRawValue: Int) {
        guard let state = MCSessionState(rawValue: stateRawValue) else { return }

        switch state {
        case .connected:
            timeoutTask?.cancel()
            let resolvedName = currentRemoteName ?? peerName
            if let deviceID = pendingOutgoingDeviceID {
                remember(deviceID: deviceID, name: pendingOutgoingName ?? peerName)
            }
            status = .syncing(peerName: resolvedName)
            sendSnapshot()
        case .connecting:
            if !status.isBusy {
                status = .connecting(peerName: currentRemoteName ?? peerName)
            }
        case .notConnected:
            if status.isBusy {
                status = .failed(message: "The nearby connection ended before syncing finished.")
            }
        @unknown default:
            status = .failed(message: "The nearby connection entered an unknown state.")
        }
    }

    private func sendSnapshot() {
        guard let context = modelContext else {
            status = .failed(message: "Local history isn’t available for syncing.")
            return
        }

        do {
            let envelope = try SyncMergeService(localDeviceID: localDeviceID).makeEnvelope(
                context: context,
                deviceName: localDeviceName
            )
            try send(WireMessage(kind: .envelope, envelope: envelope, changeCount: nil))
        } catch {
            fail("Couldn’t prepare local progress for syncing.", error: error)
        }
    }

    private func receivedData(_ data: Data) {
        do {
            let message = try JSONDecoder().decode(WireMessage.self, from: data)
            switch message.kind {
            case .envelope:
                guard let envelope = message.envelope else { throw NearbySyncError.invalidMessage }
                if let expectedDeviceID = currentRemoteDeviceID,
                   envelope.senderDeviceID != expectedDeviceID {
                    throw NearbySyncError.unexpectedDevice
                }
                guard let context = modelContext else { throw NearbySyncError.missingContext }
                let summary = try SyncMergeService(localDeviceID: localDeviceID).merge(
                    envelope,
                    into: context
                )
                let migratedCount = try CurriculumProgressMigrationService().migrate(context: context)
                Task { @MainActor in
                    await NotificationService().reconcileProblemReminders(context: context)
                }
                let (totalChanges, overflowed) = summary.changeCount.addingReportingOverflow(migratedCount)
                localMergeChangeCount = overflowed ? Int.max : totalChanges
                hasReceivedEnvelope = true
                remember(deviceID: envelope.senderDeviceID, name: envelope.senderName)
                try send(WireMessage(kind: .acknowledgement, envelope: nil, changeCount: summary.changeCount))
                finishIfComplete()
            case .acknowledgement:
                remoteMergeChangeCount = max(message.changeCount ?? 0, 0)
                hasReceivedAcknowledgement = true
                finishIfComplete()
            }
        } catch {
            fail("Couldn’t merge progress from the nearby device.", error: error)
        }
    }

    private func send(_ message: WireMessage) throws {
        guard !session.connectedPeers.isEmpty else { throw NearbySyncError.notConnected }
        let data = try JSONEncoder().encode(message)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    private func finishIfComplete() {
        guard hasReceivedEnvelope && hasReceivedAcknowledgement else { return }
        let date = Date()
        let peerName = currentRemoteName ?? "nearby device"
        let (reportedChanges, overflowed) = localMergeChangeCount.addingReportingOverflow(
            remoteMergeChangeCount
        )
        lastSyncDate = date
        UserDefaults.standard.set(date, forKey: Self.lastSyncKey)
        timeoutTask?.cancel()
        status = .synced(
            peerName: peerName,
            changes: overflowed ? Int.max : reportedChanges
        )

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1))
            self?.session.disconnect()
        }
    }

    private func resetExchangeState() {
        timeoutTask?.cancel()
        cancelPendingInvitation()
        pendingOutgoingDeviceID = nil
        pendingOutgoingName = nil
        currentRemoteDeviceID = nil
        currentRemoteName = nil
        resetExchangeFlags()
    }

    private func resetExchangeFlags() {
        hasReceivedEnvelope = false
        hasReceivedAcknowledgement = false
        localMergeChangeCount = 0
        remoteMergeChangeCount = 0
    }

    private func cancelPendingInvitation() {
        pendingInvitationHandler?.value(false, nil)
        pendingInvitationHandler = nil
        pairingRequest = nil
    }

    private func scheduleTimeout(seconds: Double, message: String) {
        timeoutTask?.cancel()
        timeoutTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(seconds))
            } catch {
                return
            }
            guard let self, status.isBusy else { return }
            browser.stopBrowsingForPeers()
            session.disconnect()
            status = .failed(message: message)
        }
    }

    private func remember(deviceID: String, name: String) {
        pairedDevices[deviceID] = PairedDevice(id: deviceID, name: name)
        persistPairedDevices()
        pairedDeviceNames = pairedDevices.values.map(\.name).sorted()
    }

    private func persistPairedDevices() {
        let devices = pairedDevices.values.sorted { $0.id < $1.id }
        if let data = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(data, forKey: Self.pairedDevicesKey)
        }
    }

    private static func loadPairedDevices(defaults: UserDefaults) -> [String: PairedDevice] {
        guard
            let data = defaults.data(forKey: pairedDevicesKey),
            let devices = try? JSONDecoder().decode([PairedDevice].self, from: data)
        else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: devices.map { ($0.id, $0) })
    }

    private func fail(_ message: String, error: Error) {
#if DEBUG
        print("CodeStreak nearby sync error: \(error)")
#endif
        timeoutTask?.cancel()
        browser.stopBrowsingForPeers()
        session.disconnect()
        cancelPendingInvitation()
        resetExchangeFlags()
        status = .failed(message: message)
    }

    private static var deviceName: String {
#if os(iOS)
        UIDevice.current.name
#elseif os(macOS)
        Host.current().localizedName ?? "Mac"
#else
        "Apple device"
#endif
    }

    private static func peerDisplayName(from name: String) -> String {
        var result = ""
        for character in name {
            let candidate = result + String(character)
            guard candidate.utf8.count <= 63 else { break }
            result = candidate
        }
        return result.isEmpty ? "CodeStreak device" : result
    }
}

private struct SyncInvitation: Codable {
    static let currentVersion = 1

    let version: Int
    let senderDeviceID: String
    let senderName: String
    let pairingCode: String?

    init(senderDeviceID: String, senderName: String, pairingCode: String?) {
        version = Self.currentVersion
        self.senderDeviceID = senderDeviceID
        self.senderName = senderName
        self.pairingCode = pairingCode
    }
}

private struct WireMessage: Codable {
    enum Kind: String, Codable {
        case envelope
        case acknowledgement
    }

    let kind: Kind
    let envelope: SyncEnvelope?
    let changeCount: Int?
}

private struct PairedDevice: Codable {
    let id: String
    let name: String
}

private enum NearbySyncError: LocalizedError {
    case invalidMessage
    case unexpectedDevice
    case missingContext
    case notConnected

    var errorDescription: String? {
        switch self {
        case .invalidMessage: "The nearby device sent an invalid message."
        case .unexpectedDevice: "The response came from an unexpected device."
        case .missingContext: "Local history isn’t available."
        case .notConnected: "The nearby device isn’t connected."
        }
    }
}

private final class UncheckedSendableBox<Value>: @unchecked Sendable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }
}

extension NearbySyncService: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        let peer = UncheckedSendableBox(peerID)
        Task { @MainActor [weak self] in
            self?.foundPeer(peer.value, discoveryInfo: info)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        Task { @MainActor [weak self] in
            self?.fail("Nearby discovery couldn’t start.", error: error)
        }
    }
}

extension NearbySyncService: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        let handler = UncheckedSendableBox(invitationHandler)
        let peerName = peerID.displayName
        Task { @MainActor [weak self] in
            self?.receivedInvitation(
                from: peerName,
                context: context,
                invitationHandler: handler
            )
        }
    }

    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        Task { @MainActor [weak self] in
            self?.isAdvertising = false
            self?.fail("Nearby availability couldn’t start.", error: error)
        }
    }
}

extension NearbySyncService: MCSessionDelegate {
    nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        let peerName = peerID.displayName
        let stateRawValue = state.rawValue
        Task { @MainActor [weak self] in
            self?.peerStateChanged(peerName: peerName, stateRawValue: stateRawValue)
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        Task { @MainActor [weak self] in
            self?.receivedData(data)
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        stream.close()
    }

    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    nonisolated func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}
