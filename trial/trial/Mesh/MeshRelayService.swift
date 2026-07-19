//
//  MeshRelayService.swift
//  Eternal Lite — Offline Mesh Relay
//
//  PURPOSE: The core MultipeerConnectivity layer. This service:
//    1. Advertises the device as a mesh peer and discovers nearby peers.
//    2. Accepts/invites peers automatically (no user interaction needed).
//    3. Receives encrypted OrderPackets from peers, verifies them, deduplicates,
//       enforces hop-count TTL, and rebroadcasts to other connected peers.
//    4. Originates packets when THIS device places an order offline.
//    5. Notifies MeshUploadService when connectivity returns so held packets
//       can be submitted to the backend.
//
//  APPLE APIS:
//    MultipeerConnectivity — MCSession, MCNearbyServiceAdvertiser,
//                            MCNearbyServiceBrowser, MCPeerID
//    Foundation — JSONEncoder/Decoder, Combine
//
//  PEER DISCOVERY MODEL:
//  ─────────────────────
//  We use BOTH advertising AND browsing simultaneously on every device. This
//  means any device can find any other device regardless of who starts first.
//  We auto-accept all invitations from peers running the same serviceType
//  ("eternallite-ord"). In a production app you would add a PIN-based pairing
//  step, but for the hackathon demo auto-accept is the right tradeoff.
//
//  SEEN-PACKET CACHE:
//  ──────────────────
//  Each device keeps a Set<UUID> of packet IDs it has already processed.
//  Before rebroadcasting, we check this set. This breaks relay loops:
//    Device A → Device B → Device C → (B already saw it — drops it)
//  The set is capped at MeshConfig.seenCacheCapacity entries. When it fills,
//  we evict the oldest half (stored in seenPacketOrder: [UUID]).
//
//  HOP COUNT TTL:
//  ──────────────
//  Each relay increments hopCount before forwarding. Packets with
//  hopCount >= MeshConfig.maxHops (5) are silently dropped. This prevents
//  a packet from bouncing indefinitely in a large mesh.
//

import Foundation
import MultipeerConnectivity
import Combine
import UIKit

// MARK: - MeshRelayService

@MainActor
public final class MeshRelayService: NSObject, ObservableObject {

    public static let shared = MeshRelayService()

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Published State (drives UI)
    // ═══════════════════════════════════════════════════════════════════

    /// Currently connected peer IDs (display names for UI)
    @Published public private(set) var connectedPeerNames: [String] = []

    /// Packets this device is currently holding (originated or relayed, not yet uploaded)
    @Published public private(set) var heldPackets: [OrderPacket] = []

    /// Tracks (packetId, peerDisplayName) pairs already sent — prevents rebroadcast
    /// from re-delivering packets that originatePacket already sent to a peer.
    private var sentDeliveries = Set<String>()

    /// Whether the mesh is actively advertising + browsing
    @Published public private(set) var isActive: Bool = false

    /// Cumulative packets this device has relayed (for debug overlay)
    @Published public private(set) var totalRelayedCount: Int = 0

    /// Last event description for the debug overlay
    @Published public private(set) var lastEvent: String = "Idle"

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - MPC Objects
    // ═══════════════════════════════════════════════════════════════════

    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Seen-Packet Deduplication Cache
    // ═══════════════════════════════════════════════════════════════════

    /// Fast membership test for already-seen packet IDs
    private var seenPacketIDs = Set<UUID>()

    /// Ordered list for LRU-style eviction when the cache is full
    private var seenPacketOrder = [UUID]()

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Dependencies + Encoder/Decoder
    // ═══════════════════════════════════════════════════════════════════

    private let signer = MeshPacketSigner.shared
    private let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }()

    // Callback invoked when a new verified packet arrives (from peer or originated here)
    // MeshUploadService subscribes to this.
    public let packetReceived = PassthroughSubject<OrderPacket, Never>()

    /// Fires when the restaurant device sends back a MeshAckPacket.
    /// MeshOrderStatusManager subscribes to drive the badge → restaurantAcknowledged.
    public let ackReceived = PassthroughSubject<MeshAckPacket, Never>()

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Init
    // ═══════════════════════════════════════════════════════════════════

    private override init() {
        // MCPeerID is the local device's identity in the mesh.
        // We use the device name (trimmed to 63 chars, MPC limit).
        myPeerID = MCPeerID(displayName: String(UIDevice.current.name.prefix(63)))
        super.init()
        buildSession()
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Session Bootstrap
    // ═══════════════════════════════════════════════════════════════════

    private func buildSession() {
        // MCSession: the actual communication channel between peers.
        // encryptionPreference = .required tells MPC to use TLS for the
        // underlying Bluetooth/WiFi-Direct transport (on top of our own
        // AES-GCM envelope — belt AND suspenders).
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self

        // Advertiser: makes this device discoverable by nearby browsers.
        // serviceType must be ≤15 chars, lowercase letters, digits, hyphens only.
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: ["app": "eternallite", "version": "1"],
            serviceType: MeshConfig.serviceType
        )
        advertiser.delegate = self

        // Browser: actively looks for advertisers nearby.
        browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: MeshConfig.serviceType
        )
        browser.delegate = self
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Start / Stop
    // ═══════════════════════════════════════════════════════════════════

    /// Start advertising and browsing. Call when the app enters foreground
    /// or when the user goes offline (to pre-warm the mesh).
    public func start() {
        guard !isActive else { return }
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        isActive = true
        lastEvent = "Mesh started — listening for peers"
        #if DEBUG
        print("📡 MeshRelay: Started advertising + browsing as '\(myPeerID.displayName)'")
        #endif
    }

    /// Stop all MPC activity. Call when the app is completely backgrounded.
    public func stop() {
        guard isActive else { return }
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        isActive = false
        lastEvent = "Mesh stopped"
        #if DEBUG
        print("📡 MeshRelay: Stopped")
        #endif
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Originate a Packet (this device placed an offline order)
    // ═══════════════════════════════════════════════════════════════════

    /// Called by the order placement flow when the device has no internet.
    /// Signs + encrypts the order, adds it to heldPackets, and broadcasts
    /// to all currently connected mesh peers.
    public func originatePacket(
        items: [ZomatoCartItem],
        restaurantId: String,
        restaurantName: String,
        deliveryAddress: String
    ) throws -> OrderPacket {

        // Build signed packet
        let packet = try signer.buildAndSign(
            items: items,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            deliveryAddress: deliveryAddress
        )

        // Mark as seen so we don't relay our own packet back to ourselves
        markSeen(packet.id)

        // Add to held packets
        heldPackets.append(packet)

        // Publish so MeshUploadService can attempt immediate upload if online
        packetReceived.send(packet)

        // Broadcast to ALL currently connected peers immediately.
        // This covers the case where peers were already connected before the order was placed.
        let connectedPeers = session.connectedPeers
        if !connectedPeers.isEmpty {
            send(packet, to: connectedPeers)
            lastEvent = "Sent order \(packet.id.uuidString.prefix(8))… to \(connectedPeers.count) peer(s)"
        } else {
            // No peers yet — packet sits in heldPackets and will be sent
            // via rebroadcastHeldPackets() when a peer connects.
            lastEvent = "Order \(packet.id.uuidString.prefix(8))… saved — waiting for peers"
        }

        #if DEBUG
        print("📤 MeshRelay: Originated packet \(packet.id) — sent to \(connectedPeers.count) peer(s), held for future peers")
        #endif

        return packet
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Remove Uploaded Packets
    // ═══════════════════════════════════════════════════════════════════

    /// Called by MeshUploadService once a packet has been confirmed by the backend.
    /// Removes it from heldPackets so it stops being relayed.
    public func markUploaded(packetId: UUID) {
        heldPackets.removeAll { $0.id == packetId }
        // Clean up delivery tracking for this packet
        sentDeliveries = sentDeliveries.filter { !$0.hasPrefix("\(packetId)|") }
        lastEvent = "Packet \(packetId.uuidString.prefix(8))… confirmed ✓"
        #if DEBUG
        print("✅ MeshRelay: Packet \(packetId) uploaded — removed from held set")
        #endif
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Rebroadcast Held Packets to a New Peer
    // ═══════════════════════════════════════════════════════════════════

    /// When a new peer connects, send them all packets we're currently holding.
    /// This handles the case where Device B reconnects after being offline —
    /// Device A immediately transfers everything it's holding.
    private func rebroadcastHeldPackets(to peer: MCPeerID) {
        let unsent = heldPackets.filter {
            !sentDeliveries.contains("\($0.id)|\(peer.displayName)")
        }
        guard !unsent.isEmpty else {
            #if DEBUG
            print("📤 MeshRelay: No new packets to send to '\(peer.displayName)' — all already delivered")
            #endif
            return
        }
        for packet in unsent {
            send(packet, to: [peer])
        }
        #if DEBUG
        print("📤 MeshRelay: Sent \(unsent.count) held packet(s) to new peer '\(peer.displayName)'")
        #endif
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Broadcast / Send
    // ═══════════════════════════════════════════════════════════════════

    /// Broadcast a packet to ALL connected peers, optionally excluding one
    /// (the peer it came from — no need to echo back).
    private func broadcast(_ packet: OrderPacket, excluding source: MCPeerID?) {
        let targets = session.connectedPeers.filter { $0 != source }
        guard !targets.isEmpty else { return }
        send(packet, to: targets)
    }

    /// Encrypt and send a packet to a specific list of peers.
    private func send(_ packet: OrderPacket, to peers: [MCPeerID]) {
        guard !peers.isEmpty else { return }
        do {
            let envelope = try signer.encrypt(packet)
            let data = try encoder.encode(envelope)
            // .reliable = TCP-like delivery guarantee over MPC transport
            try session.send(data, toPeers: peers, with: .reliable)
            // Record delivery so rebroadcast doesn't re-send to the same peer
            for peer in peers {
                sentDeliveries.insert("\(packet.id)|\(peer.displayName)")
            }
            #if DEBUG
            print("📤 MeshRelay: Sent envelope \(packet.id.uuidString.prefix(8))… to \(peers.map(\.displayName))")
            #endif
        } catch {
            #if DEBUG
            print("❌ MeshRelay: Failed to send packet \(packet.id): \(error.localizedDescription)")
            #endif
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Send Raw Data (for ACK packets from Restaurant Dashboard)
    // ═══════════════════════════════════════════════════════════════════

    /// Send pre-encoded data to ALL connected peers.
    /// Used by RestaurantDashboardView to send MeshAckPacket back to the customer.
    public func sendAckToAll(_ data: Data) throws {
        let peers = session.connectedPeers
        guard !peers.isEmpty else {
            #if DEBUG
            print("⚠️ MeshRelay: No connected peers to send ACK to")
            #endif
            return
        }
        try session.send(data, toPeers: peers, with: .reliable)
        lastEvent = "Sent ACK to \(peers.count) peer(s)"
        #if DEBUG
        print("📤 MeshRelay: Sent ACK to \(peers.map(\.displayName))")
        #endif
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Receive + Relay Pipeline
    // ═══════════════════════════════════════════════════════════════════

    /// Entry point for ALL inbound MPC data. Peeks at the leading type byte
    /// (if present) to route to the correct handler:
    ///   0x02  → MeshAckPacket from restaurant — handled by receiveAck()
    ///   0x01  → OrderPacket (new-format with prefix) — stripped and handled as order
    ///   other → legacy raw EncryptedEnvelope — handled as order for backward compat
    private func receive(data: Data, from sender: MCPeerID) {
        switch meshMessageType(from: data) {
        case .ackPacket:
            receiveAck(data, from: sender)
        case .orderPacket:
            // New-format order: strip the type byte, then treat as order
            receiveOrder(data.dropFirst(), from: sender)
        case .none:
            // Legacy format (MeshRelayService sends raw EncryptedEnvelope without prefix)
            receiveOrder(data, from: sender)
        }
    }

    // ── Ack path ────────────────────────────────────────────────────────

    /// The restaurant device sent us a MeshAckPacket confirming it received
    /// a specific OrderPacket. We publish it so MeshOrderStatusManager can
    /// update the badge to .restaurantAcknowledged.
    private func receiveAck(_ data: Data, from sender: MCPeerID) {
        do {
            let ack = try decodeMeshPayload(MeshAckPacket.self, from: data)
            ackReceived.send(ack)
            lastEvent = "🍽️ '\(sender.displayName)' acknowledged order \(ack.orderId.uuidString.prefix(8))…"
            #if DEBUG
            print("✅ MeshRelay: Received ack for order \(ack.orderId.uuidString.prefix(8))… from '\(sender.displayName)'")
            #endif
        } catch {
            #if DEBUG
            print("❌ MeshRelay: Failed to decode ack from '\(sender.displayName)': \(error)")
            #endif
        }
    }

    // ── Order path ──────────────────────────────────────────────────────

    /// Full inbound order processing pipeline:
    ///   Decrypt → Verify Signature → Deduplicate → TTL Check → Store → Rebroadcast
    private func receiveOrder(_ data: Data, from sender: MCPeerID) {
        do {
            // 1. Decode the outer EncryptedEnvelope
            let envelope = try decoder.decode(EncryptedEnvelope.self, from: data)

            // 2. Fast-path dedup using packetId on the envelope (no decryption needed)
            guard !hasSeen(envelope.packetId) else {
                #if DEBUG
                print("🔁 MeshRelay: Duplicate packet \(envelope.packetId.uuidString.prefix(8))… — dropped")
                #endif
                return
            }

            // 3. Decrypt + verify signature inside
            let packet = try signer.decrypt(envelope)

            // 4. TTL check — drop packets that have bounced too many times
            guard packet.hopCount < MeshConfig.maxHops else {
                #if DEBUG
                print("💀 MeshRelay: Packet \(packet.id.uuidString.prefix(8))… exceeded max hops (\(packet.hopCount)) — dropped")
                #endif
                return
            }

            // 5. Mark seen BEFORE rebroadcast to prevent any race condition
            markSeen(packet.id)

            // 6. Store in held packets (this device is now a relay node for this packet)
            if !heldPackets.contains(where: { $0.id == packet.id }) {
                heldPackets.append(packet)
            }

            // 7. Publish to upload service (it will attempt upload if online)
            packetReceived.send(packet)

            // 8. Increment hopCount and rebroadcast to other peers
            var relayed = packet
            relayed.hopCount += 1
            broadcast(relayed, excluding: sender)

            totalRelayedCount += 1
            lastEvent = "Relayed \(packet.id.uuidString.prefix(8))… from '\(sender.displayName)' (hop \(relayed.hopCount))"

            #if DEBUG
            print("🔀 MeshRelay: Relayed packet \(packet.id.uuidString.prefix(8))… hop=\(relayed.hopCount) to \(session.connectedPeers.filter { $0 != sender }.count) peer(s)")
            #endif

        } catch {
            #if DEBUG
            print("❌ MeshRelay: Failed to process inbound data from '\(sender.displayName)': \(error.localizedDescription)")
            #endif
            lastEvent = "Rejected tampered/invalid packet from '\(sender.displayName)'"
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Seen-Packet Cache
    // ═══════════════════════════════════════════════════════════════════

    private func hasSeen(_ id: UUID) -> Bool {
        seenPacketIDs.contains(id)
    }

    private func markSeen(_ id: UUID) {
        guard !seenPacketIDs.contains(id) else { return }

        // Evict oldest half if at capacity (simple LRU approximation)
        if seenPacketIDs.count >= MeshConfig.seenCacheCapacity {
            let half = seenPacketOrder.count / 2
            let evictees = seenPacketOrder.prefix(half)
            evictees.forEach { seenPacketIDs.remove($0) }
            seenPacketOrder.removeFirst(half)
        }

        seenPacketIDs.insert(id)
        seenPacketOrder.append(id)
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Helpers
    // ═══════════════════════════════════════════════════════════════════

    private func updateConnectedPeerNames() {
        connectedPeerNames = session.connectedPeers.map(\.displayName)
    }
}

// ═══════════════════════════════════════════════════════════════════════
// MARK: - MCSessionDelegate
// ═══════════════════════════════════════════════════════════════════════

extension MeshRelayService: MCSessionDelegate {

    /// Called on a background thread by MPC — we hop to MainActor for state updates.
    public nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        Task { @MainActor in
            switch state {
            case .connected:
                updateConnectedPeerNames()
                lastEvent = "'\(peerID.displayName)' connected (\(session.connectedPeers.count) peer(s))"
                // Forward any held packets to the newly connected peer immediately
                rebroadcastHeldPackets(to: peerID)
                #if DEBUG
                print("🟢 MeshRelay: '\(peerID.displayName)' connected — total peers: \(session.connectedPeers.count)")
                #endif

            case .notConnected:
                updateConnectedPeerNames()
                lastEvent = "'\(peerID.displayName)' disconnected"
                #if DEBUG
                print("🔴 MeshRelay: '\(peerID.displayName)' disconnected")
                #endif

            case .connecting:
                lastEvent = "Connecting to '\(peerID.displayName)'…"
                #if DEBUG
                print("🟡 MeshRelay: Connecting to '\(peerID.displayName)'")
                #endif

            @unknown default:
                break
            }
        }
    }

    /// Called when we receive raw data from a peer — this is the hot path.
    public nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            receive(data: data, from: peerID)
        }
    }

    // Required stubs — we don't use streams or resources
    public nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    public nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    public nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// ═══════════════════════════════════════════════════════════════════════
// MARK: - MCNearbyServiceAdvertiserDelegate
// ═══════════════════════════════════════════════════════════════════════

extension MeshRelayService: MCNearbyServiceAdvertiserDelegate {

    /// A nearby browser wants to connect. We auto-accept all peers running
    /// the same app (identified by serviceType). In production you'd validate
    /// the invitationHandler context object here.
    public nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        Task { @MainActor in
            // Auto-accept — all peers running "eternallite-ord" are trusted relay nodes
            invitationHandler(true, session)
            lastEvent = "Accepted invitation from '\(peerID.displayName)'"
            #if DEBUG
            print("📨 MeshRelay: Auto-accepted invitation from '\(peerID.displayName)'")
            #endif
        }
    }

    public nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Task { @MainActor in
            lastEvent = "Advertising failed: \(error.localizedDescription)"
            #if DEBUG
            print("❌ MeshRelay: Failed to start advertising: \(error)")
            #endif
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════
// MARK: - MCNearbyServiceBrowserDelegate
// ═══════════════════════════════════════════════════════════════════════

extension MeshRelayService: MCNearbyServiceBrowserDelegate {

    /// Found a nearby advertiser — immediately invite them to our session.
    public nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        Task { @MainActor in
            // Skip peers already in the session
            guard !session.connectedPeers.contains(peerID) else { return }
            // Always invite — MPC handles simultaneous cross-invites gracefully
            // by keeping only one session between any pair of peers.
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
            lastEvent = "Found peer '\(peerID.displayName)' — inviting…"
            #if DEBUG
            print("🔍 MeshRelay: Found '\(peerID.displayName)' — sent invitation")
            #endif
        }
    }

    /// A previously visible peer disappeared (moved out of range, app killed, etc.)
    public nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            lastEvent = "Lost peer '\(peerID.displayName)'"
            #if DEBUG
            print("👻 MeshRelay: Lost sight of '\(peerID.displayName)'")
            #endif
        }
    }

    public nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Task { @MainActor in
            lastEvent = "Browsing failed: \(error.localizedDescription)"
            #if DEBUG
            print("❌ MeshRelay: Failed to start browsing: \(error)")
            #endif
        }
    }
}
