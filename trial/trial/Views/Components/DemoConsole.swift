//
//  DemoConsole.swift
//  Eternal Lite — Unified Demo Instrumentation
//
//  Replaces the two stacked DebugOverlay + MeshDebugOverlay panels with a
//  single, polished bottom-sheet console that a mentor can read at a glance.
//
//  Design goals:
//  • Always-visible floating pill showing the 3 key numbers (API calls,
//    peers, network) — nothing else clutters the screen.
//  • Tap → full bottom sheet with tabbed sections: Network · Mesh · Actions.
//  • Everything readable at arm's length, large enough tap targets.
//  • One "SIMULATE OFFLINE → SIGNAL RESTORED" flow button for the demo story.
//

import SwiftUI
import Combine

// MARK: - DemoConsole

public struct DemoConsole: View {

    // Services
    @StateObject private var network  = NetworkMonitor.shared
    @StateObject private var api      = EternalLiteAPIService.shared
    @StateObject private var cache    = LiteCacheService.shared
    @StateObject private var relay    = MeshRelayService.shared
    @StateObject private var upload   = MeshUploadService.shared
    @StateObject private var status   = MeshOrderStatusManager.shared

    @State private var isSheetOpen    = false
    @State private var selectedTab    = 0          // 0=Network, 1=Mesh, 2=Actions

    public init() {}

    // MARK: - Floating Pill (always visible, minimal footprint)

    public var body: some View {
        VStack {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isSheetOpen = true
                }
            } label: {
                HStack(spacing: 8) {
                    // API call counter — the hero metric
                    apiCounterChip

                    // Network dot
                    Circle()
                        .fill(networkDotColor)
                        .frame(width: 8, height: 8)

                    // Peer count (mesh)
                    if relay.isActive {
                        HStack(spacing: 3) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(relay.connectedPeerNames.isEmpty ? .gray : .cyan)
                            Text("\(relay.connectedPeerNames.count)")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(relay.connectedPeerNames.isEmpty ? .gray : .cyan)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)
                .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.5))
            }
        }
        .sheet(isPresented: $isSheetOpen) {
            consoleSheet
        }
    }

    // MARK: - API Counter Chip

    private var apiCounterChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 9, weight: .bold))
            Text("\(api.apiCallCount)")
                .font(.system(size: 13, weight: .black, design: .monospaced))
            Text("calls")
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundColor(api.apiCallCount <= 2 ? .green : (api.apiCallCount <= 10 ? .yellow : .red))
    }

    // MARK: - Full Console Sheet

    private var consoleSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    Label("Network", systemImage: "wifi").tag(0)
                    Label("Mesh", systemImage: "antenna.radiowaves.left.and.right").tag(1)
                    Label("Actions", systemImage: "play.circle").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)

                Divider()

                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0:  networkTab
                        case 1:  meshTab
                        default: actionsTab
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Demo Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isSheetOpen = false }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Network Tab
    // ═══════════════════════════════════════════════════════════════

    private var networkTab: some View {
        VStack(spacing: 12) {
            // Hero metric
            heroCard(
                value: "\(api.apiCallCount)",
                label: "API Calls This Session",
                subtitle: api.apiCallCount <= 1 ? "✓ Batched (Eternal Lite)" : "Traditional mode",
                valueColor: api.apiCallCount <= 2 ? .green : .red,
                icon: "bolt.fill",
                iconColor: api.apiCallCount <= 2 ? .green : .red
            )

            // Status grid
            statsGrid([
                StatItem("Mode",    network.isLiteMode ? "⚡ Lite" : "🖼 Rich",   network.isLiteMode ? .yellow : .blue),
                StatItem("Network", network.connectionType.rawValue,              networkDotColor),
                StatItem("Cache",   cache.lastCacheResult,                        cache.lastCacheResult.contains("HIT") ? .green : .orange),
                StatItem("Hits",    "\(cache.cacheHitCount)",                     .green),
                StatItem("Misses",  "\(cache.cacheMissCount)",                    .red),
                StatItem("Delay",   String(format: "%.1fs", network.simulatedDelay), .secondary)
            ])

            // Network simulation
            sectionHeader("SIMULATE NETWORK")
            HStack(spacing: 10) {
                simChip("Wi-Fi", icon: "wifi",              color: .green)   { network.simulateState(connected: true,  constrained: false, expensive: false, type: .wifi) }
                simChip("Cell",  icon: "antenna.radiowaves.left.and.right", color: .yellow) { network.simulateState(connected: true,  constrained: false, expensive: true,  type: .cellular) }
                simChip("Low",   icon: "speedometer",       color: .orange)  { network.simulateState(connected: true,  constrained: true,  expensive: true,  type: .cellular) }
                simChip("Off",   icon: "wifi.slash",        color: .red)     { network.simulateState(connected: false, constrained: false, expensive: false, type: .none) }
            }

            // Reset
            HStack(spacing: 10) {
                outlineButton("Reset Counter", color: .red) {
                    api.resetCounter()
                    cache.resetCounters()
                }
                outlineButton("Clear Cache", color: .orange) {
                    cache.clearAll()
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Mesh Tab
    // ═══════════════════════════════════════════════════════════════

    private var meshTab: some View {
        VStack(spacing: 12) {
            // Mesh status hero
            HStack(spacing: 12) {
                heroCard(
                    value: "\(relay.connectedPeerNames.count)",
                    label: "Connected Peers",
                    subtitle: relay.isActive ? "Mesh active" : "Mesh stopped",
                    valueColor: relay.connectedPeerNames.isEmpty ? .secondary : .cyan,
                    icon: "person.2.wave.2",
                    iconColor: .cyan
                )
                heroCard(
                    value: "\(relay.heldPackets.count)",
                    label: "Held Packets",
                    subtitle: relay.heldPackets.isEmpty ? "Queue empty" : "Waiting to upload",
                    valueColor: relay.heldPackets.isEmpty ? .secondary : .orange,
                    icon: "tray.full",
                    iconColor: .orange
                )
            }

            statsGrid([
                StatItem("Relayed",   "\(relay.totalRelayedCount)",        .purple),
                StatItem("Confirmed", "\(upload.confirmedPackets.count)",  .green),
                StatItem("Pending ↑", "\(upload.pendingUploadCount)",      upload.pendingUploadCount > 0 ? .yellow : .secondary),
                StatItem("Mesh",      relay.isActive ? "ON" : "OFF",       relay.isActive ? .cyan : .secondary)
            ])

            // Last event log
            if !relay.lastEvent.isEmpty && relay.lastEvent != "Idle" {
                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text(relay.lastEvent)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }

            // Upload status
            if !upload.uploadStatus.isEmpty && upload.uploadStatus != "Idle" {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                    Text(upload.uploadStatus)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }

            // Connected peers list
            if !relay.connectedPeerNames.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("CONNECTED PEERS")
                    ForEach(relay.connectedPeerNames, id: \.self) { name in
                        HStack(spacing: 10) {
                            Circle().fill(Color.cyan).frame(width: 8, height: 8)
                            Text(name)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text("● connected")
                                .font(.system(size: 11))
                                .foregroundColor(.cyan)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }

            // Held packets list
            if !relay.heldPackets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("HELD PACKETS")
                    ForEach(relay.heldPackets) { packet in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.orange)
                                .frame(width: 4, height: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(packet.restaurantName)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("\(packet.id.uuidString.prefix(8).uppercased())  ·  hop \(packet.hopCount)/\(MeshConfig.maxHops)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(packet.items.count) item\(packet.items.count == 1 ? "" : "s")")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }

            // Mesh start/stop
            HStack(spacing: 10) {
                if relay.isActive {
                    outlineButton("Stop Mesh", color: .red) { relay.stop() }
                } else {
                    outlineButton("Start Mesh", color: .cyan) { relay.start() }
                }
                outlineButton("Reset State", color: .secondary) {
                    MockMeshBackend.shared.reset()
                    MeshOrderStatusManager.shared.reset()
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Actions Tab (Demo Flow)
    // ═══════════════════════════════════════════════════════════════

    private var actionsTab: some View {
        VStack(spacing: 14) {
            sectionHeader("DEMO STORY — RUN IN ORDER")

            // Step 1
            demoStepCard(
                step: "1",
                title: "Simulate No Signal",
                detail: "Sets network to fully offline. App switches to Lite mode automatically.",
                color: .red,
                buttonLabel: "Go Offline"
            ) {
                network.simulateState(connected: false, constrained: false, expensive: false, type: .none)
            }

            // Step 2
            demoStepCard(
                step: "2",
                title: "Place an Order",
                detail: "Go to Zomato → pick a restaurant → add items → checkout. The order is saved locally and broadcast to nearby mesh peers.",
                color: .orange,
                buttonLabel: nil,
                action: {}
            )

            // Step 3
            demoStepCard(
                step: "3",
                title: "Watch Relay",
                detail: "On peer devices the held-packets counter (Mesh tab) increments. The packet travels hop by hop.",
                color: .blue,
                buttonLabel: nil,
                action: {}
            )

            // Step 4 — THE HERO BUTTON
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color.green.opacity(0.15)).frame(width: 32, height: 32)
                        Text("4").font(.system(size: 15, weight: .black)).foregroundColor(.green)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Signal Restored")
                            .font(.system(size: 15, weight: .bold))
                        Text("Any peer uploads the packet. Backend deduplicates.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                Button {
                    Task {
                        network.simulateState(connected: true, constrained: false, expensive: false, type: .wifi)
                        await upload.simulateConnectivityGained()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi.circle.fill")
                            .font(.system(size: 18))
                        Text("Simulate Signal Regained")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)

            sectionHeader("EDGE CASES")

            // Force server error
            Button {
                MockMeshBackend.shared.simulateNextCallFails = true
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(.orange)
                    Text("Trigger Server Error (shows retry)")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }

            // Cellular / Low Data Mode
            Button {
                network.simulateState(connected: true, constrained: true, expensive: true, type: .cellular)
            } label: {
                HStack {
                    Image(systemName: "4g.alt").foregroundColor(.yellow)
                    Text("Switch to Low Data Mode (Lite UI)")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Reusable Sub-Views
    // ═══════════════════════════════════════════════════════════════

    private func heroCard(
        value: String, label: String, subtitle: String,
        valueColor: Color, icon: String, iconColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
                Spacer()
            }
            Text(value)
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(valueColor)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }

    private struct StatItem {
        let label: String
        let value: String
        let color: Color
        init(_ label: String, _ value: String, _ color: Color) {
            self.label = label; self.value = value; self.color = color
        }
    }

    private func statsGrid(_ items: [StatItem]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(items, id: \.label) { item in
                VStack(spacing: 3) {
                    Text(item.value)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundColor(item.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(item.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1.2)
            Spacer()
        }
    }

    private func simChip(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .cornerRadius(10)
        }
    }

    private func outlineButton(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color.opacity(0.08))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.3), lineWidth: 1))
        }
    }

    private func demoStepCard(
        step: String, title: String, detail: String,
        color: Color, buttonLabel: String?, action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(color.opacity(0.15)).frame(width: 32, height: 32)
                    Text(step).font(.system(size: 15, weight: .black)).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15, weight: .bold))
                    Text(detail).font(.system(size: 12)).foregroundColor(.secondary).lineLimit(3)
                }
                Spacer()
            }
            if let label = buttonLabel {
                Button(action: action) {
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(color.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }

    // MARK: - Colors

    private var networkDotColor: Color {
        switch network.connectionType {
        case .wifi:         return .green
        case .cellular:     return .yellow
        case .wiredEthernet:return .blue
        case .unknown:      return .gray
        case .none:         return .red
        }
    }
}

// MARK: - Color extension for .secondary shorthand in StatItem
extension Color {
    static var secondary: Color { Color(.secondaryLabel) }
}
