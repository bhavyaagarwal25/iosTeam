//
//  OrderPacket.swift
//  Eternal Lite — Offline Mesh Relay
//
//  PURPOSE: Defines the canonical wire format for an order that travels through
//  the MultipeerConnectivity mesh when the originating device has zero internet.
//
//  DESIGN DECISION — WHY ONLY COD, NO PAYMENT DATA:
//  ─────────────────────────────────────────────────
//  This packet deliberately carries ONLY an order acknowledgment — item list,
//  restaurant, delivery address, and a codFlag that is ALWAYS true.
//
//  Payment (UPI, card, wallet) is intentionally excluded because:
//
//  1. DOUBLE-SPEND RISK: A payment instruction that reaches the backend via two
//     different mesh paths would charge the customer twice. Idempotency keys help
//     but don't eliminate the race if two relay nodes upload simultaneously and
//     the payment processor deduplicates slower than the backend does.
//
//  2. FUND-VERIFICATION: Authorizing a card/UPI transaction requires a live
//     round-trip to the payment network (Visa/RuPay/NPCI). No mesh node can
//     perform that verification offline, so any "payment" in the packet would
//     be unverifiable.
//
//  3. TRUST BOUNDARY: A relay node that tampers with the amount field could
//     route an order with ₹1 instead of ₹500. Signing the packet catches
//     tampering, but only after the fact. COD moves the trust problem to
//     delivery time (when both parties are present), which is a solved UX.
//
//  COD sidesteps all three problems: no money moves until the rider hands over
//  the food, by which point the device is back online and can do a normal
//  settlement flow.
//
//  SECURITY MODEL:
//  ───────────────
//  • Signing  — Curve25519 signature over the canonical payload bytes.
//               Any relay node that mutates the packet (items, address, hopCount)
//               will break the signature, and the receiving backend will reject it.
//
//  • Encryption — AES-256-GCM per-packet symmetric key.
//               This prevents casual eavesdropping by nearby devices that are
//               NOT running the app. For the hackathon scope the symmetric key
//               is transmitted in-band (inside the encrypted envelope) — see
//               the EncryptedEnvelope struct below.
//
//  PRODUCTION NOTE ON KEY WRAPPING (not implemented for hackathon):
//  In production you would:
//    1. Each device generates a Curve25519 (or P-256) keypair on first launch.
//    2. On mesh session establishment, devices exchange their public keys.
//    3. Sender generates a random 256-bit AES-GCM key for this packet.
//    4. Sender encrypts (wraps) the AES key using the receiver's public key
//       via ECIES / HPKE (CryptoKit's `HPKE` API, available from iOS 17).
//    5. Each receiver decrypts the wrapped key with their private key, then
//       decrypts the payload.
//  This gives forward secrecy per-packet without a pre-shared secret.
//

import Foundation
import CryptoKit
import UIKit

// MARK: - OrderPacket

/// The single unit of data that travels through the mesh.
/// All fields are Codable so the struct round-trips through JSON/Data cleanly.
public struct OrderPacket: Codable, Identifiable, Hashable {

    // MARK: Core Identity

    /// Globally unique ID — used as the idempotency key on the backend.
    /// If two relay nodes both upload this packet, the backend inserts only once.
    public let id: UUID

    /// ISO-8601 wall-clock time at which the originating device created the packet.
    /// Used for TTL checks and audit trails.
    public let timestamp: Date

    // MARK: Order Contents

    /// The line items the user ordered.
    public let items: [PacketOrderItem]

    /// ID of the restaurant. Enough for the backend to look up menu/pricing.
    public let restaurantId: String

    /// Human-readable restaurant name — stored so relay nodes can display it
    /// in their debug overlay without a separate lookup.
    public let restaurantName: String

    /// Plain-text delivery address chosen by the user.
    public let deliveryAddress: String

    // MARK: Payment

    /// ALWAYS true — see the file-level comment for why payment data is excluded.
    /// The backend MUST reject any packet where codFlag == false.
    public let codFlag: Bool

    // MARK: Mesh Routing

    /// Number of hops this packet has traversed. Incremented by each relay node.
    /// Packets with hopCount >= MeshConfig.maxHops are silently dropped.
    public var hopCount: Int

    // MARK: Cryptographic Identity

    /// Base64-encoded Curve25519 public key of the originating device.
    /// Relay nodes and the backend use this to verify `signature`.
    public let originPublicKey: String

    /// Base64-encoded Curve25519 signature over the canonical payload bytes.
    /// Covers ALL fields EXCEPT `hopCount` (which relay nodes are allowed to increment)
    /// and `originDeviceSignature` itself.
    ///
    /// See MeshPacketSigner.canonicalBytes(for:) for the exact bytes being signed.
    public var originDeviceSignature: String

    // MARK: Init

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        items: [PacketOrderItem],
        restaurantId: String,
        restaurantName: String,
        deliveryAddress: String,
        codFlag: Bool = true,
        hopCount: Int = 0,
        originPublicKey: String,
        originDeviceSignature: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.items = items
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.deliveryAddress = deliveryAddress
        self.codFlag = codFlag
        self.hopCount = hopCount
        self.originPublicKey = originPublicKey
        self.originDeviceSignature = originDeviceSignature
    }
}

// MARK: - PacketOrderItem

/// Lightweight item inside an OrderPacket.
/// Carries enough info for the backend to reconstruct the order without a
/// live menu lookup.
public struct PacketOrderItem: Codable, Identifiable, Hashable {
    public let id: String           // MenuItem ID
    public let name: String         // Snapshot of display name at order time
    public let price: Double        // Snapshot of price at order time
    public let quantity: Int
    public let isVeg: Bool

    public init(id: String, name: String, price: Double, quantity: Int, isVeg: Bool) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.isVeg = isVeg
    }

    // Convenience builder from ZomatoCartItem
    public static func from(_ cartItem: ZomatoCartItem) -> PacketOrderItem {
        PacketOrderItem(
            id: cartItem.menuItem.id,
            name: cartItem.menuItem.name,
            price: cartItem.menuItem.price,
            quantity: cartItem.quantity,
            isVeg: cartItem.menuItem.isVeg
        )
    }
}

// MARK: - EncryptedEnvelope

/// Wraps an encrypted OrderPacket for transmission over the mesh.
///
/// The design here is intentionally simple for the hackathon:
///   - A random 256-bit AES-GCM key is generated per packet.
///   - The key is stored as `wrappedKey` alongside the ciphertext.
///
/// WHY THIS IS ACCEPTABLE FOR A DEMO (but not production):
///   Any device that receives the envelope can read `wrappedKey` and decrypt.
///   This means confidentiality is only as strong as physical possession of the
///   device + OS process isolation — fine for a relay mesh where all nodes run
///   the same app, but not suitable for untrusted relays.
///
/// See the file-level PRODUCTION NOTE for the ECIES/HPKE upgrade path.
public struct EncryptedEnvelope: Codable {
    /// Base64-encoded AES-256-GCM key (32 bytes).
    /// In production this would be asymmetrically wrapped per recipient.
    public let wrappedKey: String

    /// Base64-encoded AES-GCM nonce (12 bytes / 96 bits).
    public let nonce: String

    /// Base64-encoded AES-GCM ciphertext + authentication tag.
    public let ciphertext: String

    /// ID of the inner packet — needed so routers can deduplicate without decrypting.
    public let packetId: UUID

    public init(wrappedKey: String, nonce: String, ciphertext: String, packetId: UUID) {
        self.wrappedKey = wrappedKey
        self.nonce = nonce
        self.ciphertext = ciphertext
        self.packetId = packetId
    }
}

// MARK: - MeshConfig

/// Shared constants for the mesh layer.
public enum MeshConfig {
    public static let maxHops: Int = 5
    public static let seenCacheCapacity: Int = 200
    public static let serviceType: String = "eternallite-ord"
    public static var peerDisplayName: String {
        let device = UIDevice.current.name
        return String(device.prefix(60))
    }
}

// MARK: - MeshMessageType

/// 1-byte prefix written before every MPC data payload so receivers can
/// route to the right handler without peeking at the JSON.
public enum MeshMessageType: UInt8 {
    case orderPacket = 0x01
    case ackPacket   = 0x02
}

// MARK: - MeshAckPacket

/// The acknowledgment packet sent FROM the restaurant device BACK to the
/// customer device over the same MultipeerConnectivity session.
/// Tiny by design — carries only the order ID reference and prep time.
public struct MeshAckPacket: Codable {
    public let orderId: UUID
    public let receivedAt: Date
    public let restaurantDeviceName: String
    public let restaurantName: String
    public let estimatedPrepMinutes: Int

    public init(
        orderId: UUID,
        restaurantDeviceName: String,
        restaurantName: String,
        estimatedPrepMinutes: Int = 20
    ) {
        self.orderId = orderId
        self.receivedAt = Date()
        self.restaurantDeviceName = restaurantDeviceName
        self.restaurantName = restaurantName
        self.estimatedPrepMinutes = estimatedPrepMinutes
    }
}

// MARK: - Mesh Message Framing Helpers

/// Encode any Codable payload with a leading type byte.
public func encodeMeshMessage<T: Codable>(_ payload: T, type messageType: MeshMessageType) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    var data = Data([messageType.rawValue])
    data.append(try encoder.encode(payload))
    return data
}

/// Peek at the leading type byte without decoding the full payload.
public func meshMessageType(from data: Data) -> MeshMessageType? {
    guard let first = data.first else { return nil }
    return MeshMessageType(rawValue: first)
}

/// Decode the payload after stripping the leading type byte.
public func decodeMeshPayload<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: data.dropFirst())
}
