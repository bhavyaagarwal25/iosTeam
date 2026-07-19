//
//  RestaurantMeshReceiver.swift
//  RestaurantApp — Eternal Lite Demo
//
//  PURPOSE: The MPC layer for the restaurant-role device.
//  Unlike MeshRelayService (which relays), this service:
//    1. Advertises itself with the SAME serviceType so the customer app finds it.
//    2. Receives OrderPackets, decrypts + verifies signature.
//    3. Does NOT relay — it is the final destination.
//    4. Immediately sends a MeshAckPacket back to the sender.
//    5. Publishes received orders to RestaurantRootView for display.
//
//  DISCOVERY INFO: We pass {"role": "restaurant"} in the discovery info dict
//  so the customer app can optionally show "Restaurant found nearby" vs
//  "Relay peer found" in its DemoConsole. (Not strictly required for the demo.)
//

import Foundation
import MultipeerConnectivity
import Combine
import UIKit
import AudioToolbox

// MARK: - ReceivedOrder (what the UI shows)

public struct ReceivedOrder: Identifiable {
    public let id: UUID              // = packet.id
    public let packet: OrderPacket
    public let receivedAt: Date
    public var isAcknowledged: Bool  // true once we sent the ack back
    public let fromPeerName: String

    public var totalAmount: Double {
        packet.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    public var itemCount: Int {
        packet.items.reduce(0) { $0 + $1.quantity }
    }

    init(packet: OrderPacket, fromPeer: String) {
        self.id = packet.id
        self.packet = packet
        self.receivedAt = Date()
        self.isAcknowledged = false
        self.fromPeerName = fromPeer
    }
}

// MARK: - RestaurantMeshReceiver

@MainActor
public final class RestaurantMeshReceiver: NSObject, ObservableObject {

    public static let shared = RestaurantMeshReceiver()

    // MARK: - Published state

    @Published public private(set) var receivedOrders: [ReceivedOrder] = []
    @Published public private(set) var connectedCustomerNames: [String] = []
    @Published public private(set) var isListening: Bool = false
    @Published public private(set) var lastEvent: String = "Waiting for orders…"

    // Fires when a NEW order arrives — used to trigger the notification banner
    public let newOrderArrived = PassthroughSubject<ReceivedOrder, Never>()

    // MARK: - MPC objects

    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    // MARK: - Crypto

    private let signer = MeshPacketSigner.shared

    private let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }()

    // Dedup — don't show the same order twice if re-received
    private var seenOrderIDs = Set<UUID>()

    // MARK: - Init

    private override init() {
        // Prefix "REST-" so in the customer app's DemoConsole the peer name
        // clearly identifies as the restaurant device
        let deviceName = "REST-" + String(UIDevice.current.name.prefix(57))
        myPeerID = MCPeerID(displayName: deviceName)
        super.init()
        buildSession()
    }

    // MARK: - Session Setup

    private func buildSession() {
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self

        // role=restaurant in discoveryInfo helps customer app distinguish
        // relay peers from the actual restaurant endpoint
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: ["role": "restaurant", "app": "eternallite"],
            serviceType: MeshConfig.serviceType     // same as customer app
        )
        advertiser.delegate = self

        // The restaurant also browses so it can find the customer app proactively
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MeshConfig.serviceType)
        browser.delegate = self
    }

    // MARK: - Start / Stop

    public func startListening() {
        guard !isListening else { return }
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        isListening = true
        lastEvent = "Listening for orders via Bluetooth…"
        print("🍽️  RestaurantReceiver: Started as '\(myPeerID.displayName)'")
    }

    public func stopListening() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        isListening = false
        lastEvent = "Stopped"
    }

    public func clearOrders() {
        receivedOrders.removeAll()
        seenOrderIDs.removeAll()
        lastEvent = "Cleared all orders"
    }

    public func restartMesh() {
        stopListening()
        // Adding a slight delay allows the Multipeer sockets to clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.buildSession() // Rebuild session completely to fix bad state
            self?.startListening()
            self?.lastEvent = "Mesh restarted"
        }
    }

    // MARK: - Receive Pipeline

    private func handleIncomingData(_ data: Data, from sender: MCPeerID) {
        // Peek at the type byte
        guard let msgType = meshMessageType(from: data) else { return }

        switch msgType {
        case .orderPacket:
            handleIncomingOrder(data, from: sender)
        case .ackPacket:
            // Restaurant doesn't process acks — those go back to the customer
            break
        }
    }

    private func handleIncomingOrder(_ data: Data, from sender: MCPeerID) {
        do {
            // The customer app uses the old encoding (EncryptedEnvelope directly,
            // without the type-byte prefix) for backward compat with MeshRelayService.
            // We support BOTH formats:
            //   • New format: 0x01 + JSON(EncryptedEnvelope)
            //   • Legacy format: raw JSON(EncryptedEnvelope)  ← MeshRelayService sends this
            let envelopeData: Data
            if data.first == MeshMessageType.orderPacket.rawValue {
                envelopeData = data.dropFirst()
            } else {
                envelopeData = data
            }

            let envelope = try decoder.decode(EncryptedEnvelope.self, from: envelopeData)

            // Dedup
            guard !seenOrderIDs.contains(envelope.packetId) else {
                print("🔁 RestaurantReceiver: Duplicate order \(envelope.packetId.uuidString.prefix(8)) — ignored")
                return
            }

            // Decrypt + verify
            let packet = try signer.decrypt(envelope)

            seenOrderIDs.insert(packet.id)

            // Build and store the received order
            let order = ReceivedOrder(packet: packet, fromPeer: sender.displayName)
            receivedOrders.insert(order, at: 0) // newest first

            lastEvent = "New order from '\(sender.displayName)': \(packet.restaurantName)"
            print("📥 RestaurantReceiver: Order \(packet.id.uuidString.prefix(8)) received from '\(sender.displayName)'")

            // Trigger haptic + sound
            triggerOrderAlert()

            // Publish for notification banner
            newOrderArrived.send(order)

            // Send ack back to the customer device
            sendAck(for: packet, to: sender)

        } catch {
            lastEvent = "Failed to decode order: \(error.localizedDescription)"
            print("❌ RestaurantReceiver: \(error.localizedDescription)")
        }
    }

    // MARK: - Send Acknowledgment

    private func sendAck(for packet: OrderPacket, to peer: MCPeerID) {
        let ack = MeshAckPacket(
            orderId: packet.id,
            restaurantDeviceName: myPeerID.displayName,
            restaurantName: packet.restaurantName,
            estimatedPrepMinutes: 20
        )

        do {
            // Encode with type prefix so customer app can route correctly
            let data = try encodeMeshMessage(ack, type: .ackPacket)
            try session.send(data, toPeers: [peer], with: .reliable)
            print("✅ RestaurantReceiver: Sent ack for order \(packet.id.uuidString.prefix(8)) to '\(peer.displayName)'")

            // Mark as acknowledged in our list
            if let idx = receivedOrders.firstIndex(where: { $0.id == packet.id }) {
                receivedOrders[idx].isAcknowledged = true
            }
        } catch {
            print("❌ RestaurantReceiver: Failed to send ack: \(error.localizedDescription)")
        }
    }

    // MARK: - Alert

    private func triggerOrderAlert() {
        // Heavy haptic — unmistakable physical notification
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        // System sound (generic alert) as backup for when device is muted
        AudioServicesPlaySystemSound(1322) // "Tri-tone" — classic alert
    }

    private func updatePeerNames() {
        connectedCustomerNames = session.connectedPeers.map(\.displayName)
    }
}

// MARK: - MCSessionDelegate

extension RestaurantMeshReceiver: MCSessionDelegate {

    public nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            updatePeerNames()
            switch state {
            case .connected:
                lastEvent = "Customer '\(peerID.displayName)' connected"
                print("🟢 RestaurantReceiver: '\(peerID.displayName)' connected")
            case .notConnected:
                lastEvent = "'\(peerID.displayName)' disconnected"
                print("🔴 RestaurantReceiver: '\(peerID.displayName)' disconnected")
            case .connecting:
                lastEvent = "Connecting to '\(peerID.displayName)'…"
            @unknown default: break
            }
        }
    }

    public nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        Task { @MainActor in
            handleIncomingData(data, from: peerID)
        }
    }

    public nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    public nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    public nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension RestaurantMeshReceiver: MCNearbyServiceAdvertiserDelegate {

    public nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor in
            invitationHandler(true, session)
            lastEvent = "Accepted invite from '\(peerID.displayName)'"
            print("📨 RestaurantReceiver: Accepted invite from '\(peerID.displayName)'")
        }
    }

    public nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Task { @MainActor in
            lastEvent = "Advertising failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension RestaurantMeshReceiver: MCNearbyServiceBrowserDelegate {

    public nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let currentPeerID = self.myPeerID
        Task { @MainActor in
            guard !session.connectedPeers.contains(peerID) else { return }
            
            // Prevent double-invites
            if currentPeerID.hashValue > peerID.hashValue {
                browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
                lastEvent = "Found '\(peerID.displayName)' — inviting…"
                print("🔍 RestaurantReceiver: Found '\(peerID.displayName)' — inviting")
            } else {
                print("🔍 RestaurantReceiver: Found '\(peerID.displayName)' — waiting for their invitation")
            }
        }
    }

    public nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            lastEvent = "Lost peer '\(peerID.displayName)'"
        }
    }

    public nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Task { @MainActor in
            lastEvent = "Browsing failed: \(error.localizedDescription)"
        }
    }
}
