//
//  OfflineOrderQueue.swift
//  Eternal Lite — Offline Order Queueing
//
//  PURPOSE: When the user taps "Place Order" with no connectivity, instead of
//  showing an error, we queue the order locally and submit it automatically
//  when connectivity returns.
//
//  MESH INTEGRATION:
//  When the device has zero internet, enqueue() also originates a signed
//  OrderPacket via MeshRelayService so nearby devices can relay the order
//  even before this device regains signal. The mesh and direct-upload paths
//  are complementary — whichever reaches the backend first wins, and the
//  idempotency key (order.id / packet.id) prevents double-creation.
//
//  APPLE APIs:
//  - Foundation (Codable + FileManager for local queue persistence)
//  - BackgroundTasks framework (BGAppRefreshTaskRequest for retry when app is backgrounded)
//  - Network.framework (via NetworkMonitor) for connectivity detection
//
//  HACKATHON ANGLE: This is the "no dead ends" UX — even offline, the user
//  can complete their order flow. The app is honest ("we'll submit when you're
//  back online") instead of showing a generic error.
//

import Foundation
import Combine
import BackgroundTasks

/// Represents a locally-queued order waiting for connectivity
public struct QueuedOrder: Codable, Identifiable {
    public let id: String
    public let orderData: Data          // Serialized ZomatoOrder
    public let queuedAt: Date
    public var retryCount: Int
    public var lastRetryAt: Date?
    public var status: QueueStatus
    
    public enum QueueStatus: String, Codable {
        case queued = "Queued"
        case submitting = "Submitting..."
        case submitted = "Submitted"
        case failed = "Failed"
    }
    
    public init(id: String, orderData: Data, queuedAt: Date = Date()) {
        self.id = id
        self.orderData = orderData
        self.queuedAt = queuedAt
        self.retryCount = 0
        self.lastRetryAt = nil
        self.status = .queued
    }
}

@MainActor
public final class OfflineOrderQueue: ObservableObject {
    public static let shared = OfflineOrderQueue()
    
    /// Background task identifier — registered with BGTaskScheduler
    public static let backgroundTaskIdentifier = "com.eternallite.order.retry"
    
    // MARK: - Published State
    
    /// Orders waiting in the offline queue
    @Published public private(set) var queuedOrders: [QueuedOrder] = []
    
    /// Whether there are any orders waiting to be submitted
    public var hasQueuedOrders: Bool { !queuedOrders.isEmpty }
    
    /// Human-readable status for the UI
    @Published public var queueStatusMessage: String = ""
    
    // MARK: - Private
    
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    private let queueFileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        queueFileURL = appSupport.appendingPathComponent("EternalLiteQueue").appendingPathComponent("pending_orders.json")
        try? FileManager.default.createDirectory(at: queueFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        loadQueue()
        observeConnectivity()
    }
    
    // MARK: - Queue Operations
    
    /// Queue an order for submission when connectivity returns.
    /// Called when placeOrder() is tapped with no network.
    ///
    /// MESH PATH: Also originates a signed OrderPacket via MeshRelayService
    /// so nearby peer devices can relay it to the backend even if this device
    /// stays offline. The mesh path runs in parallel — whichever device (this
    /// one or a relay) reaches the backend first creates the order; the
    /// idempotency key (order.id) ensures no duplicates.
    public func enqueue(order: ZomatoOrder) {
        do {
            let orderData = try encoder.encode(order)
            let queued = QueuedOrder(id: order.id, orderData: orderData)
            queuedOrders.append(queued)
            saveQueue()
            queueStatusMessage = "Order saved — sending via nearby devices"

            // Schedule a background task to retry when the app isn't in foreground
            scheduleBackgroundRetry()

            // ── Mesh relay path ──────────────────────────────────────────
            // Originate a signed+encrypted OrderPacket into the peer mesh.
            // This is fire-and-observe: MeshUploadService watches
            // MeshRelayService.packetReceived and will upload the moment
            // any node (this device or a peer) has internet.
            Task { @MainActor in
                do {
                    let packet = try MeshRelayService.shared.originatePacket(
                        items: order.items,
                        restaurantId: order.restaurantId,
                        restaurantName: order.restaurantName,
                        deliveryAddress: order.deliveryAddress
                    )
                    // Register with status manager so MeshStatusBadge shows it
                    let hasPeers = !MeshRelayService.shared.connectedPeerNames.isEmpty
                    MeshOrderStatusManager.shared.registerAndUpdate(
                        packet: packet,
                        status: hasPeers ? .relayingNearby : .savedOnDevice
                    )
                    #if DEBUG
                    print("📡 OfflineQueue: Originated mesh packet \(packet.id.uuidString.prefix(8))…")
                    #endif
                } catch {
                    // Mesh origination failure is non-fatal — direct retry still works
                    #if DEBUG
                    print("⚠️  OfflineQueue: Mesh origination failed: \(error.localizedDescription)")
                    #endif
                }
            }

            #if DEBUG
            print("📥 OfflineQueue: Enqueued order \(order.id) — \(queuedOrders.count) orders pending")
            #endif
        } catch {
            #if DEBUG
            print("❌ OfflineQueue: Failed to encode order: \(error)")
            #endif
        }
    }
    
    /// Attempt to submit all queued orders. Called when connectivity returns.
    public func processQueue() async {
        guard networkMonitor.isConnected else {
            queueStatusMessage = "Still offline — \(queuedOrders.count) order(s) waiting"
            return
        }
        
        guard !queuedOrders.isEmpty else { return }
        
        queueStatusMessage = "Submitting \(queuedOrders.count) queued order(s)..."
        
        for i in queuedOrders.indices {
            queuedOrders[i].status = .submitting
            
            // Simulate API submission with delay
            try? await Task.sleep(for: .seconds(1.0))
            
            if networkMonitor.isConnected {
                queuedOrders[i].status = .submitted
                queuedOrders[i].lastRetryAt = Date()
                
                #if DEBUG
                print("✅ OfflineQueue: Submitted order \(queuedOrders[i].id)")
                #endif
            } else {
                queuedOrders[i].status = .failed
                queuedOrders[i].retryCount += 1
                
                #if DEBUG
                print("❌ OfflineQueue: Failed to submit order \(queuedOrders[i].id) — retry #\(queuedOrders[i].retryCount)")
                #endif
            }
        }
        
        // Remove successfully submitted orders
        let submittedCount = queuedOrders.filter { $0.status == .submitted }.count
        queuedOrders.removeAll { $0.status == .submitted }
        saveQueue()
        
        if queuedOrders.isEmpty {
            queueStatusMessage = "All \(submittedCount) order(s) submitted successfully! ✓"
        } else {
            queueStatusMessage = "\(queuedOrders.count) order(s) still pending — will retry"
        }
    }
    
    // MARK: - Connectivity Observer
    
    /// Watch for connectivity changes. When network returns, process the queue.
    private func observeConnectivity() {
        networkMonitor.$isConnected
            .removeDuplicates()
            .filter { $0 == true } // Only react when connectivity is RESTORED
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self, self.hasQueuedOrders else { return }
                    #if DEBUG
                    print("🌐 OfflineQueue: Connectivity restored — processing queue")
                    #endif
                    await self.processQueue()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Background Task (for when app is not in foreground)
    
    /// Schedule a BGAppRefreshTask to retry order submission in the background.
    /// Apple API: BackgroundTasks framework
    private func scheduleBackgroundRetry() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Retry in 1 minute
        
        do {
            try BGTaskScheduler.shared.submit(request)
            #if DEBUG
            print("⏰ OfflineQueue: Scheduled background retry task")
            #endif
        } catch {
            #if DEBUG
            print("❌ OfflineQueue: Failed to schedule background task: \(error)")
            #endif
        }
    }
    
    /// Handle the background task when it fires.
    /// Called from trialApp's background task registration.
    public func handleBackgroundTask(_ task: BGTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task { @MainActor in
            await processQueue()
            task.setTaskCompleted(success: queuedOrders.isEmpty)
            
            // Re-schedule if there are still pending orders
            if hasQueuedOrders {
                scheduleBackgroundRetry()
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveQueue() {
        do {
            let data = try encoder.encode(queuedOrders)
            try data.write(to: queueFileURL)
        } catch {
            #if DEBUG
            print("❌ OfflineQueue: Failed to save queue: \(error)")
            #endif
        }
    }
    
    private func loadQueue() {
        guard let data = try? Data(contentsOf: queueFileURL),
              let orders = try? decoder.decode([QueuedOrder].self, from: data) else {
            return
        }
        queuedOrders = orders
        
        #if DEBUG
        if !orders.isEmpty {
            print("📂 OfflineQueue: Loaded \(orders.count) pending order(s) from disk")
        }
        #endif
    }
    
    /// Clear all queued orders (for demo reset)
    public func clearQueue() {
        queuedOrders.removeAll()
        saveQueue()
        queueStatusMessage = ""
    }
}
