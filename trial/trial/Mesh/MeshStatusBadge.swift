//
//  MeshStatusBadge.swift
//  Eternal Lite — Offline Mesh Relay
//
//  PURPOSE: A small, calm status pill that surfaces the mesh order lifecycle
//  to the user. The design principle is "honest but not alarming" — the user
//  knows their order is in-flight without feeling like something is broken.
//
//  STATE TRANSITIONS (matching MeshOrderStatus):
//    📦 "Saved on device"   — amber pill, pulsing gently (offline, no peers)
//    📡 "Relaying nearby"   — blue pill, animated radio waves (peers connected)
//    ✓  "Confirmed"         — green pill, brief checkmark pop (backend acked)
//    ⚠️  "Failed"            — red pill (rare, only for rejected packets)
//
//  USAGE — drop anywhere in a ZStack over the order confirmation screen:
//
//    MeshStatusBadge()                        // shows latestEntry from manager
//    MeshStatusBadge(packetId: someUUID)      // shows status for a specific order
//
//  The badge auto-hides 4 seconds after reaching "confirmed" so it doesn't
//  permanently clutter the UI.
//

import SwiftUI

// MARK: - MeshStatusBadge

public struct MeshStatusBadge: View {

    /// If nil, shows status for the most recent order (latestEntry)
    public var packetId: UUID?

    @StateObject private var statusManager = MeshOrderStatusManager.shared
    @State private var isVisible: Bool = true
    @State private var pulseScale: CGFloat = 1.0
    @State private var waveOpacity: Double = 0.0
    @State private var confirmScale: CGFloat = 0.5
    @State private var confirmOpacity: Double = 0.0

    public init(packetId: UUID? = nil) {
        self.packetId = packetId
    }

    // MARK: - Computed Entry

    private var entry: MeshOrderStatusEntry? {
        if let id = packetId {
            return statusManager.entries.first { $0.id == id }
        }
        return statusManager.latestEntry
    }

    private var status: MeshOrderStatus? { entry?.status }

    // MARK: - Body

    public var body: some View {
        Group {
            if let status, isVisible {
                pill(for: status)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: status)
                    .onChange(of: status) { _, newStatus in
                        handleTransition(to: newStatus)
                    }
                    .onAppear {
                        handleTransition(to: status)
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isVisible)
    }

    // MARK: - Pill

    @ViewBuilder
    private func pill(for status: MeshOrderStatus) -> some View {
        HStack(spacing: 7) {
            // Leading indicator — animated per state
            leadingIndicator(for: status)

            // Label
            Text(status.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(textColor(for: status))
                .lineLimit(1)

            // Trailing context (confirmation ID or relay count)
            trailingDetail(for: status)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(backgroundColor(for: status))
                .shadow(color: shadowColor(for: status).opacity(0.25), radius: 6, x: 0, y: 3)
        )
        .overlay(
            Capsule()
                .stroke(borderColor(for: status).opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Leading Indicator

    @ViewBuilder
    private func leadingIndicator(for status: MeshOrderStatus) -> some View {
        switch status {
        case .savedOnDevice:
            Image(systemName: "internaldrive")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(amberColor)
                .scaleEffect(pulseScale)

        case .relayingNearby:
            ZStack {
                Circle()
                    .stroke(blueColor.opacity(waveOpacity * 0.4), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                Circle()
                    .stroke(blueColor.opacity(waveOpacity * 0.7), lineWidth: 1.5)
                    .frame(width: 12, height: 12)
                Circle()
                    .fill(blueColor)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 18, height: 18)

        case .restaurantAcknowledged:
            // Fork & knife — unmistakably "the restaurant has it"
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(greenColor)
                .scaleEffect(confirmScale)
                .opacity(confirmOpacity)

        case .confirmed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(greenColor)
                .scaleEffect(confirmScale)
                .opacity(confirmOpacity)

        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Trailing Detail

    @ViewBuilder
    private func trailingDetail(for status: MeshOrderStatus) -> some View {
        switch status {
        case .confirmed(let confirmId):
            Text("· \(String(confirmId.suffix(8)))")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(greenColor.opacity(0.8))

        case .restaurantAcknowledged(let deviceName, let prepMins):
            // Show trimmed device name + prep time — gives mentor something concrete to read
            let shortName = deviceName
                .replacingOccurrences(of: "REST-", with: "")
                .replacingOccurrences(of: "'s iPhone", with: "")
            Text("· \(shortName)  ~\(prepMins)m")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(greenColor.opacity(0.8))

        case .relayingNearby:
            let peerCount = MeshRelayService.shared.connectedPeerNames.count
            if peerCount > 0 {
                Text("· \(peerCount) peer\(peerCount == 1 ? "" : "s")")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(blueColor.opacity(0.8))
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Animations

    private func handleTransition(to status: MeshOrderStatus) {
        switch status {
        case .savedOnDevice:
            startPulseAnimation()

        case .relayingNearby:
            startWaveAnimation()

        case .restaurantAcknowledged:
            // Same pop-in as confirmed — the restaurant has the order
            startConfirmAnimation()
            // Keep visible for 6s (longer than confirmed — this is the demo money shot)
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isVisible = false
                }
            }

        case .confirmed:
            startConfirmAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isVisible = false
                }
            }

        case .failed:
            break
        }
    }

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.15
        }
    }

    private func startWaveAnimation() {
        withAnimation(
            .easeOut(duration: 1.0)
            .repeatForever(autoreverses: false)
        ) {
            waveOpacity = 1.0
        }
    }

    private func startConfirmAnimation() {
        // Spring pop for the checkmark
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
            confirmScale = 1.0
            confirmOpacity = 1.0
        }
    }

    // MARK: - Colours

    private var amberColor: Color { Color(red: 0.95, green: 0.65, blue: 0.0) }
    private var blueColor: Color  { Color(red: 0.2,  green: 0.5,  blue: 0.95) }
    private var greenColor: Color { Color(red: 0.1,  green: 0.72, blue: 0.3) }

    private func backgroundColor(for status: MeshOrderStatus) -> Color {
        switch status {
        case .savedOnDevice:          return Color(red: 0.98, green: 0.93, blue: 0.78)
        case .relayingNearby:         return Color(red: 0.88, green: 0.93, blue: 1.0)
        case .restaurantAcknowledged: return Color(red: 0.88, green: 0.97, blue: 0.89)
        case .confirmed:              return Color(red: 0.88, green: 0.97, blue: 0.89)
        case .failed:                 return Color(red: 0.95, green: 0.25, blue: 0.2)
        }
    }

    private func textColor(for status: MeshOrderStatus) -> Color {
        switch status {
        case .savedOnDevice:          return Color(red: 0.55, green: 0.38, blue: 0.0)
        case .relayingNearby:         return Color(red: 0.1,  green: 0.3,  blue: 0.75)
        case .restaurantAcknowledged: return Color(red: 0.05, green: 0.45, blue: 0.15)
        case .confirmed:              return Color(red: 0.05, green: 0.45, blue: 0.15)
        case .failed:                 return .white
        }
    }

    private func borderColor(for status: MeshOrderStatus) -> Color {
        switch status {
        case .savedOnDevice:          return amberColor
        case .relayingNearby:         return blueColor
        case .restaurantAcknowledged: return greenColor
        case .confirmed:              return greenColor
        case .failed:                 return .red
        }
    }

    private func shadowColor(for status: MeshOrderStatus) -> Color {
        switch status {
        case .savedOnDevice:          return amberColor
        case .relayingNearby:         return blueColor
        case .restaurantAcknowledged: return greenColor
        case .confirmed:              return greenColor
        case .failed:                 return .red
        }
    }
}

// MARK: - MeshStatusBadgeStack
// Shows the last N mesh order statuses — useful on the order confirmation screen
// when multiple offline orders were queued.

public struct MeshStatusBadgeStack: View {
    @StateObject private var statusManager = MeshOrderStatusManager.shared

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Show at most 3 recent entries to avoid overwhelming the UI
            ForEach(statusManager.entries.prefix(3)) { entry in
                HStack(spacing: 8) {
                    // Tiny restaurant context
                    if !entry.restaurantName.isEmpty && entry.restaurantName != "Order" {
                        Text(entry.restaurantName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .frame(maxWidth: 100, alignment: .leading)
                    }
                    MeshStatusBadge(packetId: entry.id)
                }
            }
        }
    }
}

#Preview("Status Badge States") {
    VStack(spacing: 20) {
        Text("Mesh Status Badge").font(.headline)

        // Preview each state by directly constructing the pill
        // (Can't easily inject status in preview without a full manager mock,
        //  so we show the colour/shape system via raw pill views)
        HStack(spacing: 8) {
            Image(systemName: "internaldrive").foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.0))
            Text("Saved on device").font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.55, green: 0.38, blue: 0.0))
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Capsule().fill(Color(red: 0.98, green: 0.93, blue: 0.78)))

        HStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right").foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.95))
            Text("Relaying nearby").font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.75))
            Text("· 2 peers").font(.system(size: 10)).foregroundColor(.blue.opacity(0.8))
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Capsule().fill(Color(red: 0.88, green: 0.93, blue: 1.0)))

        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(red: 0.1, green: 0.72, blue: 0.3))
            Text("Confirmed").font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.05, green: 0.45, blue: 0.15))
            Text("· MESH-1A2B").font(.system(size: 10, design: .monospaced)).foregroundColor(.green.opacity(0.8))
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Capsule().fill(Color(red: 0.88, green: 0.97, blue: 0.89)))
    }
    .padding(32)
}
