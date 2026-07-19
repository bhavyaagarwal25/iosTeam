//
//  MeshDebugOverlay.swift
//  Eternal Lite — Offline Mesh Relay
//
//  PURPOSE: Demo-time instrumentation panel for the mesh layer. Shows:
//    • Connected peer count and names
//    • Packets currently held locally (waiting for upload)
//    • Upload service status
//    • Relay statistics (total relayed, backend dedup count)
//    • Manual simulation controls for the live demo
//
//  PLACEMENT: Overlaid as a draggable/dismissable sheet anchored to the
//  bottom-right corner. Sits alongside the existing DebugOverlay (for
//  network/API stats) — they are separate views to keep concerns isolated.
//
//  The overlay is only visible when #if DEBUG or when the user has
//  explicitly enabled it via the existing DebugOverlay's expanded panel.
//

import SwiftUI
import Combine

public struct MeshDebugOverlay: View {

    @StateObject private var relay    = MeshRelayService.shared
    @StateObject private var upload   = MeshUploadService.shared
    @StateObject private var backend  = DebugBackendProxy()
    @StateObject private var network  = NetworkMonitor.shared

    @State private var isExpanded: Bool = false
    @State private var showPeerList: Bool = false
    @State private var showPacketList: Bool = false

    public init() {}

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // ── Compact Pill ──────────────────────────────────────────────
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    // Mesh active indicator
                    Circle()
                        .fill(relay.isActive ? Color.cyan : Color.gray)
                        .frame(width: 7, height: 7)

                    // Peer count
                    Image(systemName: "person.2.wave.2")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(relay.connectedPeerNames.isEmpty ? .gray : .cyan)
                    Text("\(relay.connectedPeerNames.count)")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(relay.connectedPeerNames.isEmpty ? .gray : .cyan)

                    // Held packets
                    Image(systemName: "envelope.badge")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(relay.heldPackets.isEmpty ? .gray : .orange)
                    Text("\(relay.heldPackets.count)")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(relay.heldPackets.isEmpty ? .gray : .orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.65))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.cyan.opacity(0.3), lineWidth: 0.5))
            }

            // ── Expanded Panel ────────────────────────────────────────────
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {

                    // Header
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                            .foregroundColor(.cyan)
                        Text("MESH RELAY")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                        Spacer()
                        // Active/Inactive toggle
                        Button(relay.isActive ? "Stop" : "Start") {
                            if relay.isActive { relay.stop() } else { relay.start() }
                        }
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(relay.isActive ? .red : .green)
                    }

                    Divider().background(Color.white.opacity(0.15))

                    // ── Stats rows ────────────────────────────────────────
                    statRow("Peers",      value: "\(relay.connectedPeerNames.count)",   color: relay.connectedPeerNames.isEmpty ? .gray : .cyan)
                    statRow("Held pkts",  value: "\(relay.heldPackets.count)",          color: relay.heldPackets.isEmpty ? .gray : .orange)
                    statRow("Relayed",    value: "\(relay.totalRelayedCount)",          color: .purple)
                    statRow("Confirmed",  value: "\(upload.confirmedPackets.count)",    color: .green)
                    statRow("Pending ↑",  value: "\(upload.pendingUploadCount)",        color: upload.pendingUploadCount > 0 ? .yellow : .gray)

                    // Upload status
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 9)).foregroundColor(.gray)
                        Text(upload.uploadStatus)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }

                    // Last event
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 9)).foregroundColor(.gray)
                        Text(relay.lastEvent)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    }

                    Divider().background(Color.white.opacity(0.15))

                    // ── Connected Peers ───────────────────────────────────
                    if !relay.connectedPeerNames.isEmpty {
                        DisclosureGroup(
                            isExpanded: $showPeerList,
                            content: {
                                VStack(alignment: .leading, spacing: 3) {
                                    ForEach(relay.connectedPeerNames, id: \.self) { name in
                                        HStack(spacing: 5) {
                                            Circle().fill(Color.cyan).frame(width: 5, height: 5)
                                            Text(name)
                                                .font(.system(size: 9))
                                                .foregroundColor(.white.opacity(0.8))
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            },
                            label: {
                                Text("Peers (\(relay.connectedPeerNames.count))")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                        )
                        .accentColor(.cyan)
                    }

                    // ── Held Packets ──────────────────────────────────────
                    if !relay.heldPackets.isEmpty {
                        DisclosureGroup(
                            isExpanded: $showPacketList,
                            content: {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(relay.heldPackets) { packet in
                                        HStack(spacing: 5) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.orange.opacity(0.6))
                                                .frame(width: 3, height: 16)
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(packet.restaurantName)
                                                    .font(.system(size: 9, weight: .semibold))
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .lineLimit(1)
                                                Text("\(packet.id.uuidString.prefix(8))… · hop \(packet.hopCount)")
                                                    .font(.system(size: 8, design: .monospaced))
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            },
                            label: {
                                Text("Held (\(relay.heldPackets.count))")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                        )
                        .accentColor(.orange)

                        Divider().background(Color.white.opacity(0.15))
                    }

                    // ── Demo Controls ─────────────────────────────────────
                    Text("SIMULATE").font(.system(size: 8, weight: .bold)).foregroundColor(.gray)

                    // Network state row (reuses existing NetworkMonitor sim)
                    HStack(spacing: 5) {
                        simButton("WiFi", color: .green) {
                            network.simulateState(connected: true, constrained: false, expensive: false, type: .wifi)
                        }
                        simButton("Cell", color: .yellow) {
                            network.simulateState(connected: true, constrained: false, expensive: true, type: .cellular)
                        }
                        simButton("Off", color: .red) {
                            network.simulateState(connected: false, constrained: false, expensive: false, type: .none)
                        }
                    }

                    // The hero demo button: simulate regained connectivity
                    // This triggers MeshUploadService to flush all held packets
                    Button {
                        Task {
                            network.simulateState(connected: true, constrained: false, expensive: false, type: .wifi)
                            await upload.simulateConnectivityGained()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "wifi.circle.fill")
                                .font(.system(size: 12))
                            Text("Simulate Signal Regained")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(Capsule())
                    }

                    // Force a server error on next upload (to demo retry)
                    Button {
                        MockMeshBackend.shared.simulateNextCallFails = true
                    } label: {
                        Text("Simulate Server Error (next upload)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Divider().background(Color.white.opacity(0.15))

                    // Reset all mesh state
                    Button {
                        MockMeshBackend.shared.reset()
                        MeshOrderStatusManager.shared.reset()
                    } label: {
                        Text("Reset Mesh State")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan.opacity(0.2), lineWidth: 0.5))
                .frame(width: 210)
            }
        }
    }

    // MARK: - Helpers

    private func statRow(_ label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 72, alignment: .leading)
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }

    private func simButton(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(color.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}

// MARK: - DebugBackendProxy
// Thin ObservableObject wrapper so the view can observe MockMeshBackend
// (which is not itself an ObservableObject — it uses @MainActor directly).

@MainActor
private final class DebugBackendProxy: ObservableObject {
    @Published var confirmedCount: Int = 0
    private var timer: Timer?

    init() {
        // Poll every second — cheap since it's just an Int read
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                let count = MockMeshBackend.shared.confirmedOrderCount
                self?.confirmedCount = count
                self?.objectWillChange.send()
            }
        }
    }

    deinit { timer?.invalidate() }
}

#Preview {
    ZStack(alignment: .topTrailing) {
        Color.black.ignoresSafeArea()
        MeshDebugOverlay()
            .padding(.top, 60)
            .padding(.trailing, 12)
    }
}
