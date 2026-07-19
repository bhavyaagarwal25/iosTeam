//
//  KeychainService.swift
//  Eternal Lite — Mesh Security Layer
//
//  PURPOSE: Generates, stores, and retrieves the device's Curve25519 signing keypair
//  from the iOS Keychain. The keypair is created once on first launch and persists
//  across app restarts (but NOT across device wipes or reinstalls — intentional,
//  since the identity is device-scoped, not account-scoped).
//
//  WHY KEYCHAIN (not UserDefaults or FileManager):
//  ─────────────────────────────────────────────────
//  • UserDefaults: plaintext, backed up to iCloud by default, readable by other
//    processes with the same entitlement group. NOT suitable for private keys.
//  • FileManager: protected by Data Protection (kSecAttrAccessibleAfterFirstUnlock)
//    if you set the file attributes correctly, but requires manual management.
//  • Keychain: OS-managed encrypted storage, hardware-backed on devices with Secure
//    Enclave. Access controlled per-app. Automatically excluded from iCloud backups
//    when kSecAttrSynchronizable = false. The right tool for crypto keys.
//
//  APPLE APIS USED:
//  • Security framework: SecItemAdd, SecItemCopyMatching, SecItemDelete
//  • CryptoKit: Curve25519.Signing.PrivateKey, .PublicKey
//

import Foundation
import Security
import CryptoKit

// MARK: - KeychainError

public enum KeychainError: Error, LocalizedError {
    case unexpectedStatus(OSStatus)
    case dataConversionFailed
    case itemNotFound
    case duplicateItem

    public var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status):
            return "Keychain OSStatus: \(status)"
        case .dataConversionFailed:
            return "Failed to convert keychain data"
        case .itemNotFound:
            return "Item not found in Keychain"
        case .duplicateItem:
            return "Item already exists in Keychain"
        }
    }
}

// MARK: - KeychainService

/// Thread-safe Keychain wrapper for the device's Curve25519 signing keypair.
/// Call `sharedKeypair()` anywhere in the mesh layer — it's cheap after the
/// first call (returns the cached in-memory keypair).
public final class KeychainService {

    public static let shared = KeychainService()

    // MARK: - Keychain Labels

    private enum Keys {
        /// Account tag used to store/retrieve the raw private key bytes.
        static let privateKeyAccount = "com.eternallite.mesh.signing.privatekey"
        /// Service name (app-level namespace).
        static let service = "com.eternallite.mesh"
    }

    // MARK: - In-Memory Cache

    /// Cached keypair — avoids a Keychain round-trip on every sign/verify call.
    private var _cachedKeypair: MeshKeypair?
    private let lock = NSLock()

    private init() {}

    // MARK: - Public API

    /// Returns the device's persistent signing keypair.
    /// Creates and stores a new one on first call (first app launch).
    public func sharedKeypair() throws -> MeshKeypair {
        lock.lock()
        defer { lock.unlock() }

        // Fast path: in-memory cache
        if let cached = _cachedKeypair { return cached }

        // Try to load from Keychain
        if let privateKeyData = try? loadFromKeychain(account: Keys.privateKeyAccount) {
            let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyData)
            let keypair = MeshKeypair(privateKey: privateKey)
            _cachedKeypair = keypair
            return keypair
        }

        // First launch: generate + persist
        let privateKey = Curve25519.Signing.PrivateKey()
        try saveToKeychain(data: privateKey.rawRepresentation, account: Keys.privateKeyAccount)

        let keypair = MeshKeypair(privateKey: privateKey)
        _cachedKeypair = keypair

        #if DEBUG
        print("🔑 KeychainService: Generated new Curve25519 signing keypair")
        print("   Public key: \(keypair.publicKeyBase64.prefix(24))…")
        #endif

        return keypair
    }

    /// Returns just the public key as base64 — safe to share with peers and embed in packets.
    public func publicKeyBase64() throws -> String {
        return try sharedKeypair().publicKeyBase64
    }

    /// Wipes the stored keypair from Keychain AND clears the in-memory cache.
    /// Use only for testing / factory-reset scenarios.
    public func deleteKeypair() throws {
        lock.lock()
        defer { lock.unlock() }

        try deleteFromKeychain(account: Keys.privateKeyAccount)
        _cachedKeypair = nil

        #if DEBUG
        print("🗑️ KeychainService: Deleted signing keypair")
        #endif
    }

    // MARK: - Low-Level Keychain Operations

    private func saveToKeychain(data: Data, account: String) throws {
        let query: [CFString: Any] = [
            kSecClass:              kSecClassGenericPassword,
            kSecAttrService:        Keys.service,
            kSecAttrAccount:        account,
            kSecValueData:          data,
            // Never sync to iCloud — private keys must stay on-device
            kSecAttrSynchronizable: kCFBooleanFalse!,
            // Accessible after first unlock: survives device lock but not reboot
            // without first being unlocked once. Good balance of security/usability.
            kSecAttrAccessible:     kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                // Already exists — update instead
                let updateQuery: [CFString: Any] = [
                    kSecClass:       kSecClassGenericPassword,
                    kSecAttrService: Keys.service,
                    kSecAttrAccount: account
                ]
                let updateAttrs: [CFString: Any] = [kSecValueData: data]
                let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttrs as CFDictionary)
                guard updateStatus == errSecSuccess else {
                    throw KeychainError.unexpectedStatus(updateStatus)
                }
                return
            }
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func loadFromKeychain(account: String) throws -> Data {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      Keys.service,
            kSecAttrAccount:      account,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne,
            kSecAttrSynchronizable: kCFBooleanFalse!
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound { throw KeychainError.itemNotFound }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.dataConversionFailed
        }

        return data
    }

    private func deleteFromKeychain(account: String) throws {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: Keys.service,
            kSecAttrAccount: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

// MARK: - MeshKeypair

/// Value type wrapping a Curve25519 signing keypair.
/// Exposes base64 helpers so the keys can be embedded in Codable structs.
public struct MeshKeypair {
    public let privateKey: Curve25519.Signing.PrivateKey

    public var publicKey: Curve25519.Signing.PublicKey {
        privateKey.publicKey
    }

    /// Base64-encoded raw bytes of the public key (32 bytes → 44 base64 chars).
    public var publicKeyBase64: String {
        privateKey.publicKey.rawRepresentation.base64EncodedString()
    }

    /// Sign arbitrary data. Returns base64-encoded signature.
    public func sign(data: Data) throws -> String {
        let signature = try privateKey.signature(for: data)
        return signature.base64EncodedString()
    }

    init(privateKey: Curve25519.Signing.PrivateKey) {
        self.privateKey = privateKey
    }
}
