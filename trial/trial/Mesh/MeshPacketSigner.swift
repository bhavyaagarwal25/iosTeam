//
//  MeshPacketSigner.swift
//  Eternal Lite — Mesh Security Layer
//
//  PURPOSE: Signs outgoing OrderPackets and verifies incoming ones.
//  Also handles AES-256-GCM encryption/decryption for the EncryptedEnvelope
//  wire format used between mesh peers.
//
//  WHAT GETS SIGNED vs. WHAT GETS ENCRYPTED:
//  ───────────────────────────────────────────
//  Signing covers the IMMUTABLE fields of the packet — the fields that prove
//  the original device authored this specific order with these specific items.
//  hopCount is deliberately EXCLUDED from the signed bytes because relay nodes
//  are permitted (and expected) to increment it as the packet traverses hops.
//  If we signed hopCount, the first relay would break the signature.
//
//  Encryption wraps the ENTIRE serialised packet (including the signature) in
//  AES-256-GCM. This means:
//    • The signature proves authorship (tamper-evident).
//    • The encryption provides confidentiality from passive sniffers.
//
//  APPLE APIS USED:
//  • CryptoKit: Curve25519.Signing, AES.GCM, SymmetricKey
//  • Foundation: JSONEncoder / JSONDecoder
//

import Foundation
import CryptoKit

// MARK: - MeshSigningError

public enum MeshSigningError: Error, LocalizedError {
    case signingFailed(String)
    case verificationFailed
    case invalidPublicKey
    case encryptionFailed(String)
    case decryptionFailed(String)
    case invalidNonce
    case encodingFailed

    public var errorDescription: String? {
        switch self {
        case .signingFailed(let msg):    return "Signing failed: \(msg)"
        case .verificationFailed:        return "Signature verification failed — packet may have been tampered with"
        case .invalidPublicKey:          return "Cannot decode origin public key"
        case .encryptionFailed(let msg): return "Encryption failed: \(msg)"
        case .decryptionFailed(let msg): return "Decryption failed: \(msg)"
        case .invalidNonce:              return "Invalid AES-GCM nonce"
        case .encodingFailed:            return "JSON encoding/decoding failed"
        }
    }
}

// MARK: - MeshPacketSigner

/// Stateless utility that signs, verifies, encrypts, and decrypts OrderPackets.
/// All methods are pure functions; no stored state beyond the JSONEncoder/Decoder
/// pair (reused for performance).
public final class MeshPacketSigner {

    public static let shared = MeshPacketSigner()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        // Deterministic output — same packet always produces same canonical bytes.
        e.outputFormatting = [.sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private init() {}

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Signing
    // ═══════════════════════════════════════════════════════════════════

    /// Build and sign a new OrderPacket from ZomatoCartItems.
    ///
    /// Flow:
    ///   1. Convert cart items → PacketOrderItems (snapshot prices/names).
    ///   2. Build a DRAFT packet with an empty signature placeholder.
    ///   3. Compute canonical bytes over the draft's immutable fields.
    ///   4. Sign with the device's Curve25519 private key (from Keychain).
    ///   5. Return the final packet with the real signature embedded.
    public func buildAndSign(
        items: [ZomatoCartItem],
        restaurantId: String,
        restaurantName: String,
        deliveryAddress: String
    ) throws -> OrderPacket {

        let keypair = try KeychainService.shared.sharedKeypair()

        // Convert cart items to lightweight packet items (snapshot)
        let packetItems = items.map { PacketOrderItem.from($0) }

        // Build draft with empty signature so we can compute canonical bytes
        let draft = OrderPacket(
            items: packetItems,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            deliveryAddress: deliveryAddress,
            codFlag: true,          // Always COD — see OrderPacket.swift for rationale
            hopCount: 0,
            originPublicKey: keypair.publicKeyBase64,
            originDeviceSignature: "" // placeholder
        )

        // Compute bytes that will be signed
        let bytesToSign = try canonicalBytes(for: draft)

        // Sign
        let signatureBase64 = try keypair.sign(data: bytesToSign)

        // Return the final packet with the real signature
        return OrderPacket(
            id: draft.id,
            timestamp: draft.timestamp,
            items: draft.items,
            restaurantId: draft.restaurantId,
            restaurantName: draft.restaurantName,
            deliveryAddress: draft.deliveryAddress,
            codFlag: true,
            hopCount: 0,
            originPublicKey: keypair.publicKeyBase64,
            originDeviceSignature: signatureBase64
        )
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Verification
    // ═══════════════════════════════════════════════════════════════════

    /// Verify the signature on an incoming packet.
    ///
    /// Returns `true` if the packet's contents haven't been tampered with
    /// since the originating device signed them.
    ///
    /// NOTE: This does NOT verify that the originating device is "trusted" in
    /// any allowlist sense — it only proves the payload wasn't mutated in
    /// transit. A backend would additionally check the public key against a
    /// registered device registry.
    @discardableResult
    public func verify(_ packet: OrderPacket) throws -> Bool {
        // Decode the origin's public key from the packet
        guard let pubKeyData = Data(base64Encoded: packet.originPublicKey) else {
            throw MeshSigningError.invalidPublicKey
        }
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: pubKeyData)

        // Decode the signature
        guard let signatureData = Data(base64Encoded: packet.originDeviceSignature) else {
            throw MeshSigningError.verificationFailed
        }

        // Recompute canonical bytes (same deterministic function used at signing time)
        let signedBytes = try canonicalBytes(for: packet)

        // Verify
        guard publicKey.isValidSignature(signatureData, for: signedBytes) else {
            throw MeshSigningError.verificationFailed
        }

        return true
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Canonical Bytes
    // ═══════════════════════════════════════════════════════════════════

    /// Produces the deterministic byte sequence that is signed and verified.
    ///
    /// INCLUDED (immutable — define what was ordered):
    ///   id, timestamp, items, restaurantId, restaurantName,
    ///   deliveryAddress, codFlag, originPublicKey
    ///
    /// EXCLUDED (mutable — relay nodes are allowed to change these):
    ///   hopCount           — incremented at each relay hop (by design)
    ///   originDeviceSignature — not yet set when computing bytes to sign
    ///
    /// Using JSONEncoder with .sortedKeys guarantees that two encodings of the
    /// same logical struct produce byte-identical output regardless of property
    /// declaration order.
    public func canonicalBytes(for packet: OrderPacket) throws -> Data {
        // Build a reduced struct that contains only the fields we sign over
        let canonical = CanonicalPacketFields(
            id: packet.id,
            timestamp: packet.timestamp,
            items: packet.items,
            restaurantId: packet.restaurantId,
            restaurantName: packet.restaurantName,
            deliveryAddress: packet.deliveryAddress,
            codFlag: packet.codFlag,
            originPublicKey: packet.originPublicKey
        )
        do {
            return try encoder.encode(canonical)
        } catch {
            throw MeshSigningError.encodingFailed
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Encryption (AES-256-GCM)
    // ═══════════════════════════════════════════════════════════════════

    /// Encrypt a signed OrderPacket into an EncryptedEnvelope for wire transmission.
    ///
    /// Steps:
    ///   1. JSON-encode the full packet (including signature).
    ///   2. Generate a fresh 256-bit SymmetricKey and 96-bit random nonce.
    ///   3. Encrypt with AES.GCM (authenticated encryption — provides both
    ///      confidentiality and integrity/tamper-detection via the GCM tag).
    ///   4. Base64-encode everything and bundle into EncryptedEnvelope.
    ///
    /// HACKATHON SIMPLIFICATION:
    ///   The symmetric key is stored as `wrappedKey` in the envelope — any peer
    ///   that receives the envelope can decrypt. See OrderPacket.swift for the
    ///   PRODUCTION NOTE on asymmetric key wrapping with HPKE/ECIES.
    public func encrypt(_ packet: OrderPacket) throws -> EncryptedEnvelope {
        // 1. Serialise the full packet
        let packetData: Data
        do {
            packetData = try encoder.encode(packet)
        } catch {
            throw MeshSigningError.encodingFailed
        }

        // 2. Generate a fresh symmetric key for this packet (one-time use)
        let symmetricKey = SymmetricKey(size: .bits256)

        // 3. Encrypt with AES-256-GCM
        //    CryptoKit generates a random nonce internally when using
        //    AES.GCM.seal(_:using:) — we extract and store it separately so
        //    the receiver can reconstruct the SealedBox.
        let sealedBox: AES.GCM.SealedBox
        do {
            sealedBox = try AES.GCM.seal(packetData, using: symmetricKey)
        } catch {
            throw MeshSigningError.encryptionFailed(error.localizedDescription)
        }

        // 4. Bundle into EncryptedEnvelope
        return EncryptedEnvelope(
            wrappedKey: symmetricKey.withUnsafeBytes { Data($0).base64EncodedString() },
            nonce: sealedBox.nonce.withUnsafeBytes { Data($0).base64EncodedString() },
            // combined = nonce + ciphertext + tag — but we store nonce separately,
            // so here we store just ciphertext + tag for clarity
            ciphertext: (sealedBox.ciphertext + sealedBox.tag).base64EncodedString(),
            packetId: packet.id
        )
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Decryption
    // ═══════════════════════════════════════════════════════════════════

    /// Decrypt an EncryptedEnvelope and return the inner OrderPacket.
    ///
    /// Also verifies the packet's Curve25519 signature after decryption so
    /// that any in-transit tampering is detected before the packet is acted on.
    public func decrypt(_ envelope: EncryptedEnvelope) throws -> OrderPacket {
        // 1. Decode key
        guard let keyData = Data(base64Encoded: envelope.wrappedKey) else {
            throw MeshSigningError.decryptionFailed("Invalid wrapped key encoding")
        }
        let symmetricKey = SymmetricKey(data: keyData)

        // 2. Decode nonce
        guard let nonceData = Data(base64Encoded: envelope.nonce),
              let nonce = try? AES.GCM.Nonce(data: nonceData) else {
            throw MeshSigningError.invalidNonce
        }

        // 3. Decode ciphertext + tag
        guard let ciphertextAndTag = Data(base64Encoded: envelope.ciphertext) else {
            throw MeshSigningError.decryptionFailed("Invalid ciphertext encoding")
        }

        // The last 16 bytes are the GCM authentication tag
        guard ciphertextAndTag.count > 16 else {
            throw MeshSigningError.decryptionFailed("Ciphertext too short")
        }
        let ciphertext = ciphertextAndTag.dropLast(16)
        let tag = ciphertextAndTag.suffix(16)

        // 4. Reconstruct SealedBox and decrypt
        let sealedBox: AES.GCM.SealedBox
        let plaintext: Data
        do {
            sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
            plaintext = try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            throw MeshSigningError.decryptionFailed(error.localizedDescription)
        }

        // 5. Decode packet
        let packet: OrderPacket
        do {
            packet = try decoder.decode(OrderPacket.self, from: plaintext)
        } catch {
            throw MeshSigningError.decryptionFailed("JSON decode failed: \(error.localizedDescription)")
        }

        // 6. Verify signature — reject tampered packets immediately
        try verify(packet)

        return packet
    }
}

// MARK: - CanonicalPacketFields (private signing contract)

/// Internal struct that defines EXACTLY which fields are signed.
/// Making this a separate type ensures the signing contract is explicit and
/// can never accidentally include a new field added to OrderPacket later.
private struct CanonicalPacketFields: Codable {
    let id: UUID
    let timestamp: Date
    let items: [PacketOrderItem]
    let restaurantId: String
    let restaurantName: String
    let deliveryAddress: String
    let codFlag: Bool
    let originPublicKey: String
    // hopCount intentionally omitted — relay nodes may increment it
    // originDeviceSignature intentionally omitted — not available at signing time
}
