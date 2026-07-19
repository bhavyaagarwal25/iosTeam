//
//  MeshOrderStatusManager.swift
//  Eternal Lite — Offline Mesh Relay
//
//  PURPOSE: Single source of truth for the per-order mesh status that drives
//  the MeshStatusBadge UI. Tracks the lifecycle of every packet:
//
//    savedOnDevice  →  relayingNearby  →  confirmed
//         │                  │               │
//    (no signal,       (peers found,    (backend ack
//     no peers)         relaying)        received)
//
//  The transition to `confirmed` also triggers a Live Activity update via
//  the existing OrderService/LiveActivityManager so the lock screen reflects
//  the confirmation — the user never has to open the app to see it resolved.
//
//  DESIGN: MeshStatusBadge observes this manager directly. MeshUploadService
//  calls update(packetId:status:) as state transitions happen. There is no
//  polling — all updates are push-based.
//

import Foundation
import Combine

// MARK: - MeshOrderStatus

public enum MeshOrderStatus: Equatable {
    /// Packet saved locally, no peers connected and no internet
    case savedOnDevice

    /// At least one mesh peer is connected and actively relaying the packet
    case relayingNearby

    /// The restaurant's device received the packet and sent back an acknowledgment.
    /// This is the key demo state — proof of real device-to-device delivery.
    /// - deviceName: display name of the restaurant iPhone ("REST-Rahul's iPhone")
    /// - prepMinutes: estimated prep time echoed from the restaurant app
    case restaurantAcknowledged(deviceName: String, prepMinutes: Int)

    /// Backend confirmed the order (direct or via relay)
    case confirmed(confirmationId: String)

    /// Permanent rejection from the backend
    case failed(reason: String)

    // MARK: Display Helpers

    public var label: String {
        switch self {
        case .savedOnDevice:                        return "Saved on device"
        case .relayingNearby:                       return "Relaying nearby"
        case .restaurantAcknowledged:               return "Restaurant received ✓"
        case .confirmed:                            return "Confirmed"
        case .failed:                               return "Failed"
        }
    }

    public var symbolName: String {
        switch self {
        case .savedOnDevice:                        return "internaldrive"
        case .relayingNearby:                       return "antenna.radiowaves.left.and.right"
        case .restaurantAcknowledged:               return "fork.knife.circle.fill"
        case .confirmed:                            return "checkmark.circle.fill"
        case .failed:                               return "exclamationmark.triangle.fill"
        }
    }

    /// Colour token — used by MeshStatusBadge
    public var colorName: String {
        switch self {
        case .savedOnDevice:                        return "amber"
        case .relayingNearby:                       return "blue"
        case .restaurantAcknowledged:               return "green"
        case .confirmed:                            return "green"
        case .failed:                               return "red"
        }
    }

    public var isTerminal: Bool {
        switch self {
        // restaurantAcknowledged is terminal for the demo — the order is at the restaurant.
        // confirmed is terminal — backend has it.
        // Both mean "done from user's perspective".
        case .restaurantAcknowledged, .confirmed, .failed: return true
        default:                                            return false
        }
    }

    // Equatable manually because associated-value cases need it
    public static func == (lhs: MeshOrderStatus, rhs: MeshOrderStatus) -> Bool {
        switch (lhs, rhs) {
        case (.savedOnDevice, .savedOnDevice):     return true
        case (.relayingNearby, .relayingNearby):   return true
        case (.restaurantAcknowledged(let a, let b), .restaurantAcknowledged(let c, let d)):
            return a == c && b == d
        case (.confirmed(let a), .confirmed(let b)):return a == b
        case (.failed(let a), .failed(let b)):      return a == b
        default:                                    return false
        }
    }
}

// MARK: - MeshOrderStatusEntry

/// One row in the status registry — one entry per tracked packet.
public struct MeshOrderStatusEntry: Identifiable {
    public let id: UUID             // = packet.id
    public let restaurantName: String
    public let itemCount: Int
    public var status: MeshOrderStatus
    public var updatedAt: Date
    public let createdAt: Date

    public init(id: UUID, restaurantName: String, itemCount: Int, status: MeshOrderStatus) {
        self.id = id
        self.restaurantName = restaurantName
        self.itemCount = itemCount
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - MeshOrderStatusManager

@MainActor
public final class MeshOrderStatusManager: ObservableObject {

    public static let shared = MeshOrderStatusManager()

    // MARK: - Published State

    /// All tracked orders in reverse-chronological order (most recent first)
    @Published public private(set) var entries: [MeshOrderStatusEntry] = []

    /// The most recently updated entry — MeshStatusBadge shows this one
    @Published public private(set) var latestEntry: MeshOrderStatusEntry? = nil

    // MARK: - Private

    private var entryMap: [UUID: Int] = [:]  // packetId → index in entries[]
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Subscribe to restaurant acks from the relay service.
        // When the restaurant iPhone sends back a MeshAckPacket, MeshRelayService
        // fires ackReceived — we update that order's status immediately so the
        // MeshStatusBadge transitions to .restaurantAcknowledged without any
        // user action required.
        MeshRelayService.shared.ackReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ack in
                self?.update(
                    packetId: ack.orderId,
                    status: .restaurantAcknowledged(
                        deviceName: ack.restaurantDeviceName,
                        prepMinutes: ack.estimatedPrepMinutes
                    )
                )
                #if DEBUG
                print("📋 StatusManager: Order \(ack.orderId.uuidString.prefix(8))… → restaurantAcknowledged by '\(ack.restaurantDeviceName)'")
                #endif
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    /// Register a new packet and set its initial status.
    /// Called by MeshUploadService.enqueue() when a packet first arrives.
    public func register(packet: OrderPacket) {
        guard entryMap[packet.id] == nil else { return }

        let entry = MeshOrderStatusEntry(
            id: packet.id,
            restaurantName: packet.restaurantName,
            itemCount: packet.items.reduce(0) { $0 + $1.quantity },
            status: .savedOnDevice
        )
        entries.insert(entry, at: 0)     // most recent first
        rebuildMap()
        latestEntry = entries.first

        #if DEBUG
        print("📋 StatusManager: Registered packet \(packet.id.uuidString.prefix(8))… for '\(packet.restaurantName)'")
        #endif
    }

    /// Update the status of a tracked packet.
    /// Called by MeshUploadService as state transitions happen.
    public func update(packetId: UUID, status: MeshOrderStatus) {
        // Auto-register if we haven't seen this packet yet (relay path)
        if entryMap[packetId] == nil {
            // We don't have full packet context here — create a minimal entry
            let entry = MeshOrderStatusEntry(
                id: packetId,
                restaurantName: "Order",
                itemCount: 0,
                status: status
            )
            entries.insert(entry, at: 0)
            rebuildMap()
        } else {
            guard let idx = entryMap[packetId] else { return }
            entries[idx].status = status
            entries[idx].updatedAt = Date()

            // Re-sort so the most recently updated floats to the top
            entries.sort { $0.updatedAt > $1.updatedAt }
            rebuildMap()
        }

        latestEntry = entries.first

        #if DEBUG
        print("📋 StatusManager: \(packetId.uuidString.prefix(8))… → \(status.label)")
        #endif
    }

    /// Register + set initial status in one call (convenience for originatePacket flow)
    public func registerAndUpdate(packet: OrderPacket, status: MeshOrderStatus) {
        register(packet: packet)
        update(packetId: packet.id, status: status)
    }

    /// The status for a specific packet (for per-order badge in order list)
    public func status(for packetId: UUID) -> MeshOrderStatus? {
        guard let idx = entryMap[packetId] else { return nil }
        return entries[idx].status
    }

    /// Clear all entries (demo reset)
    public func reset() {
        entries.removeAll()
        entryMap.removeAll()
        latestEntry = nil
    }

    // MARK: - Private Helpers

    private func rebuildMap() {
        entryMap.removeAll(keepingCapacity: true)
        for (idx, entry) in entries.enumerated() {
            entryMap[entry.id] = idx
        }
    }
}
