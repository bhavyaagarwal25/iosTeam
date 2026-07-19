//
//  RestaurantRootView.swift
//  RestaurantApp — Eternal Lite Demo
//
//  The main screen of the Restaurant app.
//  Designed to look like a real KDS (Kitchen Display System) —
//  professional, high-contrast, easy to read from across a kitchen counter.
//
//  Layout:
//   ┌─────────────────────────────────────────┐
//   │  🍽️  ETERNAL LITE  ●  2 peers   [mesh]  │  ← header
//   │  "Waiting for orders…"                  │  ← status
//   ├─────────────────────────────────────────┤
//   │  ┌─────────────────────────────────┐   │
//   │  │  IncomingOrderCard (newest top)  │   │
//   │  └─────────────────────────────────┘   │
//   │  ┌─────────────────────────────────┐   │
//   │  │  IncomingOrderCard              │   │
//   │  └─────────────────────────────────┘   │
//   └─────────────────────────────────────────┘
//

import SwiftUI
import Combine

public struct RestaurantRootView: View {

    @EnvironmentObject private var receiver: RestaurantMeshReceiver

    // Notification banner state
    @State private var bannerOrder: ReceivedOrder? = nil
    @State private var bannerVisible = false
    @State private var cancellable: AnyCancellable?

    private let zomatoRed = Color(red: 0.90, green: 0.10, blue: 0.20)

    public var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                statusBar

                if receiver.receivedOrders.isEmpty {
                    emptyState
                } else {
                    orderList
                }
            }

            // New-order notification banner (slides in from top)
            if bannerVisible, let order = bannerOrder {
                newOrderBanner(order)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .onAppear {
            receiver.startListening()
            subscribeToBanners()
        }
        .onDisappear {
            receiver.stopListening()
        }
    }

    // ── HEADER BAR ─────────────────────────────────────────────────────
    private var headerBar: some View {
        HStack(spacing: 12) {
            // App identity
            HStack(spacing: 8) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(zomatoRed)
                VStack(alignment: .leading, spacing: 1) {
                    Text("ETERNAL LITE")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.primary)
                    Text("Restaurant Dashboard")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Peer / mesh status chip
            HStack(spacing: 6) {
                Circle()
                    .fill(receiver.connectedCustomerNames.isEmpty ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(receiver.connectedCustomerNames.isEmpty ? .orange : .green)
                Text(receiver.connectedCustomerNames.isEmpty ? "No peers" : "\(receiver.connectedCustomerNames.count) peer\(receiver.connectedCustomerNames.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(receiver.connectedCustomerNames.isEmpty ? .orange : .green)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                receiver.connectedCustomerNames.isEmpty
                    ? Color.orange.opacity(0.1)
                    : Color.green.opacity(0.1)
            )
            .clipShape(Capsule())
            
            // Menu for reloading/resetting
            Menu {
                Button(action: { receiver.clearOrders() }) {
                    Label("Clear Orders", systemImage: "trash")
                }
                Button(action: { receiver.restartMesh() }) {
                    Label("Restart Mesh", systemImage: "arrow.triangle.2.circlepath")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 14)
        .background(Color(uiColor: .systemBackground))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // ── STATUS BAR ─────────────────────────────────────────────────────
    private var statusBar: some View {
        HStack(spacing: 8) {
            // Order count
            if !receiver.receivedOrders.isEmpty {
                Text("\(receiver.receivedOrders.count) ORDER\(receiver.receivedOrders.count == 1 ? "" : "S") TODAY")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(zomatoRed)
                    .tracking(1)
            }

            Spacer()

            // Last event
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text(receiver.lastEvent)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemBackground))
    }

    // ── EMPTY STATE ────────────────────────────────────────────────────
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(width: 120, height: 120)
                Image(systemName: "bell.slash")
                    .font(.system(size: 44))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                Text("No orders yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Text(receiver.connectedCustomerNames.isEmpty
                     ? "Waiting for customer app to connect…"
                     : "Customer app connected. Place an order to see it appear here.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Peer names
            if !receiver.connectedCustomerNames.isEmpty {
                VStack(spacing: 6) {
                    Text("CONNECTED DEVICES")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.secondary)
                        .tracking(1)
                    ForEach(receiver.connectedCustomerNames, id: \.self) { name in
                        HStack(spacing: 8) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text(name)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
    }

    // ── ORDER LIST ─────────────────────────────────────────────────────
    private var orderList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(receiver.receivedOrders) { order in
                    IncomingOrderCard(order: order)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    // ── NEW ORDER BANNER ───────────────────────────────────────────────
    private func newOrderBanner(_ order: ReceivedOrder) -> some View {
        HStack(spacing: 14) {
            // Flashing bell
            Image(systemName: "bell.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("NEW ORDER!")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Text("\(order.packet.restaurantName)  ·  \(order.itemCount) item\(order.itemCount == 1 ? "" : "s")  ·  ₹\(Int(order.totalAmount))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }

            Spacer()

            // Packet ID (proof for mentor)
            Text("#\(order.packet.id.uuidString.prefix(6).uppercased())")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(zomatoRed)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: zomatoRed.opacity(0.4), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.top, 60)
    }

    // ── BANNER SUBSCRIPTION ────────────────────────────────────────────
    private func subscribeToBanners() {
        cancellable = receiver.newOrderArrived
            .receive(on: DispatchQueue.main)
            .sink { order in
                bannerOrder = order
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    bannerVisible = true
                }
                // Auto-dismiss after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        bannerVisible = false
                    }
                }
            }
    }
}
