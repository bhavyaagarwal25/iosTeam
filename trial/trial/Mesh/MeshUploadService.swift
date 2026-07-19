//
//  MeshUploadService.swift
//  Eternal Lite — Offline Mesh Relay
//
//  PURPOSE: The bridge between the mesh relay layer and the backend.
//  Watches two signals:
//    1. MeshRelayService.packetReceived — a new packet arrived (originated or relayed)
//    2. NetworkMonitor.$isConnected — connectivity state changed
//
//  When BOTH signals are true (we have a packet AND we have internet), this
//  service attempts upload. It uses the same BackgroundTasks retry pattern as
//  OfflineOrderQueue so the upload can happen even when the app is backgrounded.
//
//  IDEMPOTENCY / DEDUP:
//  ─────────────────────
//  Multiple relay devices may each regain connectivity and independently call
//  submit() for the same packet. That's fine — MockMeshBackend.submit() is
//  idempotent on packet.id. This service also maintains its own
//  `uploadedPacketIDs` set so it doesn't attempt the same upload twice from
//  within a single app session (avoids hammering the backend with retries for
//  a packet it already confirmed this session).
//
//  BACKGROUND RETRY:
//  ─────────────────
//  Uses BGAppRefreshTaskRequest (same identifier namespace as OfflineOrderQueue
//  but a distinct task ID) so uploads can complete even if the user backgrounds
//  the app right after regaining signal.
//
//  APPLE APIS: Combine, BackgroundTasks, Foundation
//

import Foundation
import Combine
import BackgroundTasks

@MainActor
public final class MeshUploadService: ObservableObject {

    public static let shared = MeshUploadService()

    // Background task identifier — registered in Info.plist BGTaskSchedulerPermittedIdentifiers
    public static let backgroundTaskIdentifier = "com.eternallite.mesh.upload"

    // MARK: - Published State

    /// Packets that have been submitted but are waiting for a backend ack
    @Published public private(set) var pendingUploadCount: Int = 0

    /// Packets confirmed by the backend this session (packetId → confirmationId)
    @Published public private(set) var confirmedPackets: [UUID: String] = [:]

    /// Current upload activity description (for debug overlay)
    @Published public private(set) var uploadStatus: String = "Idle"

    // MARK: - Private State

    /// Per-session dedup: IDs we've already successfully uploaded.
    /// Prevents retry hammering when packetReceived fires multiple times.
    private var uploadedPacketIDs = Set<UUID>()

    /// Packets queued for upload (received before connectivity returned)
    private var pendingPackets: [UUID: OrderPacket] = [:]

    // MARK: - Dependencies

    private let relay = MeshRelayService.shared
    private let backend = MockMeshBackend.shared
    private let networkMonitor = NetworkMonitor.shared
    private let statusManager = MeshOrderStatusManager.shared

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    private init() {
        subscribeToPackets()
        subscribeToConnectivity()
    }

    // MARK: - Subscriptions

    /// Every packet that passes through the relay layer (originated or received)
    /// lands here. We queue it and attempt upload if we're online.
    private func subscribeToPackets() {
        relay.packetReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] packet in
                Task { @MainActor [weak self] in
                    await self?.enqueue(packet)
                }
            }
            .store(in: &cancellables)
    }

    /// When connectivity is restored, flush the pending queue.
    private func subscribeToConnectivity() {
        networkMonitor.$isConnected
            .removeDuplicates()
            .filter { $0 == true }
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, !self.pendingPackets.isEmpty else { return }
                    #if DEBUG
                    print("🌐 MeshUpload: Connectivity restored — flushing \(self.pendingPackets.count) pending packet(s)")
                    #endif
                    await self.flushPendingQueue()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Enqueue

    /// Add a packet to the pending upload set and attempt upload immediately
    /// if we're connected. Otherwise it waits for the connectivity subscription
    /// to fire.
    private func enqueue(_ packet: OrderPacket) async {
        // Skip packets already confirmed this session
        guard !uploadedPacketIDs.contains(packet.id) else { return }
        // Skip if already queued
        guard pendingPackets[packet.id] == nil else { return }

        pendingPackets[packet.id] = packet
        pendingUploadCount = pendingPackets.count

        // Update order status to "relaying" if peers are connected, else "saved"
        let status: MeshOrderStatus = relay.connectedPeerNames.isEmpty ? .savedOnDevice : .relayingNearby
        statusManager.update(packetId: packet.id, status: status)

        if networkMonitor.isConnected {
            await upload(packet)
        } else {
            uploadStatus = "\(pendingPackets.count) packet(s) queued — waiting for signal"
            scheduleBackgroundRetry()
        }
    }

    // MARK: - Upload

    /// Attempt to upload a single packet to the backend.
    private func upload(_ packet: OrderPacket) async {
        uploadStatus = "Uploading order \(packet.id.uuidString.prefix(8))…"

        let result = await backend.submit(packet: packet)

        switch result {
        case .created(let confirmationId):
            handleSuccess(packet: packet, confirmationId: confirmationId)

        case .alreadyProcessed(let confirmationId):
            // Another relay node got there first — still a success for this device
            handleSuccess(packet: packet, confirmationId: confirmationId)

        case .rejected(let reason):
            // Permanent failure — remove from queue, don't retry
            pendingPackets.removeValue(forKey: packet.id)
            pendingUploadCount = pendingPackets.count
            statusManager.update(packetId: packet.id, status: .failed(reason: reason))
            uploadStatus = "Rejected: \(reason)"
            #if DEBUG
            print("❌ MeshUpload: Packet \(packet.id.uuidString.prefix(8))… rejected — \(reason)")
            #endif

        case .serverError(let msg):
            // Transient failure — keep in queue for retry
            uploadStatus = "Server error (\(msg)) — will retry"
            scheduleBackgroundRetry()
            #if DEBUG
            print("⚠️  MeshUpload: Transient error for \(packet.id.uuidString.prefix(8))… — \(msg)")
            #endif
        }
    }

    private func handleSuccess(packet: OrderPacket, confirmationId: String) {
        uploadedPacketIDs.insert(packet.id)
        pendingPackets.removeValue(forKey: packet.id)
        confirmedPackets[packet.id] = confirmationId
        pendingUploadCount = pendingPackets.count

        // Tell the relay layer to stop holding/rebroadcasting this packet
        relay.markUploaded(packetId: packet.id)

        // Update UI status to confirmed
        statusManager.update(packetId: packet.id, status: .confirmed(confirmationId: confirmationId))

        uploadStatus = pendingPackets.isEmpty
            ? "All orders confirmed ✓"
            : "\(pendingPackets.count) remaining…"

        #if DEBUG
        print("✅ MeshUpload: Confirmed \(packet.id.uuidString.prefix(8))… → '\(confirmationId)'")
        #endif
    }

    // MARK: - Flush Queue

    /// Upload all currently pending packets concurrently.
    /// Safe to call multiple times — uploadedPacketIDs prevents double-submission.
    public func flushPendingQueue() async {
        guard !pendingPackets.isEmpty else { return }
        guard networkMonitor.isConnected else {
            uploadStatus = "No connectivity — \(pendingPackets.count) order(s) queued"
            return
        }

        uploadStatus = "Uploading \(pendingPackets.count) queued order(s)…"

        // Snapshot the current keys — pendingPackets may mutate during async loop
        let ids = Array(pendingPackets.keys)
        await withTaskGroup(of: Void.self) { group in
            for id in ids {
                if let packet = pendingPackets[id] {
                    group.addTask { @MainActor in
                        await self.upload(packet)
                    }
                }
            }
        }
    }

    // MARK: - Background Task

    private func scheduleBackgroundRetry() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30)
        try? BGTaskScheduler.shared.submit(request)
    }

    /// Handle a BGAppRefreshTask firing. Called from trialApp.
    public func handleBackgroundTask(_ task: BGTask) {
        task.expirationHandler = { task.setTaskCompleted(success: false) }
        Task { @MainActor in
            await flushPendingQueue()
            task.setTaskCompleted(success: pendingPackets.isEmpty)
            if !pendingPackets.isEmpty { scheduleBackgroundRetry() }
        }
    }

    // MARK: - Demo Helper

    /// Force a simulated connectivity gain (for the debug overlay "simulate" button)
    public func simulateConnectivityGained() async {
        uploadStatus = "Simulating connectivity restored…"
        await flushPendingQueue()
    }
}
