//
//  MeshEventLogger.swift
//  Eternal Lite — Mesh Relay
//
//  PURPOSE: Append-only timestamped event log for the mesh layer.
//  Every meaningful action — peer connected, packet sent, packet received,
//  signature verified, upload confirmed — is recorded here with a timestamp
//  and a source device name.
//
//  WHY THIS MATTERS FOR THE DEMO:
//  Your mentor can look at this log and read exactly what happened:
//    14:32:01  📱 Shubh's iPhone    Originated packet 3F2A1B for "Pizza Hut"
//    14:32:02  📡 Rahul's iPhone    Received + relayed (hop 1 → 2)
//    14:32:09  ☁️  Backend           Order confirmed ORD-MESH-3F2A1B
//
//  That's irrefutable real-time proof. No mentor can doubt it.
//

import Foundation
import Combine
import UIKit

// MARK: - MeshEvent

public struct MeshEvent: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let kind: Kind
    public let deviceName: String
    public let detail: String

    public enum Kind {
        case peerConnected
        case peerDisconnected
        case packetOriginated
        case packetRelayed
        case packetReceived
        case signatureVerified
        case signatureFailed
        case uploadAttempted
        case uploadConfirmed
        case uploadDuplicate   // another relay already submitted
        case uploadFailed
        case meshStarted
        case meshStopped

        var emoji: String {
            switch self {
            case .peerConnected:     return "🟢"
            case .peerDisconnected:  return "🔴"
            case .packetOriginated:  return "📤"
            case .packetRelayed:     return "🔀"
            case .packetReceived:    return "📥"
            case .signatureVerified: return "🔐"
            case .signatureFailed:   return "⛔"
            case .uploadAttempted:   return "☁️"
            case .uploadConfirmed:   return "✅"
            case .uploadDuplicate:   return "♻️"
            case .uploadFailed:      return "⚠️"
            case .meshStarted:       return "📡"
            case .meshStopped:       return "📵"
            }
        }

        var color: String {   // color name resolved in view
            switch self {
            case .peerConnected, .signatureVerified, .uploadConfirmed: return "green"
            case .peerDisconnected, .signatureFailed, .uploadFailed:   return "red"
            case .packetOriginated, .packetRelayed, .packetReceived:   return "blue"
            case .uploadAttempted, .meshStarted:                       return "cyan"
            case .uploadDuplicate:                                     return "orange"
            case .meshStopped:                                         return "gray"
            }
        }
    }

    public var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: timestamp)
    }

    public var shortDevice: String {
        // Trim "iPhone" / "Simulator" suffix to keep UI tight
        deviceName
            .replacingOccurrences(of: "'s iPhone", with: "")
            .replacingOccurrences(of: "'s iPad", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - MeshEventLogger

@MainActor
public final class MeshEventLogger: ObservableObject {

    public static let shared = MeshEventLogger()

    @Published public private(set) var events: [MeshEvent] = []

    private let myDevice = UIDevice.current.name
    private let maxEvents = 100   // keep log bounded

    private init() {}

    /// Log an event from this device.
    public func log(_ kind: MeshEvent.Kind, detail: String, device: String? = nil) {
        let event = MeshEvent(
            timestamp: Date(),
            kind: kind,
            deviceName: device ?? myDevice,
            detail: detail
        )
        events.insert(event, at: 0)   // newest first
        if events.count > maxEvents {
            events.removeLast()
        }
    }

    /// Clear (for demo reset)
    public func clear() { events.removeAll() }
}
