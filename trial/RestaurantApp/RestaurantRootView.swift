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
        NavigationStack {
            ZStack(alignment: .top) {
                if receiver.receivedOrders.isEmpty {
                    emptyState
                } else {
                    orderList
                }

                // New-order notification banner (slides in from top)
                if bannerVisible, let order = bannerOrder {
                    newOrderBanner(order)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Eternal Lite")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    peerStatusMenu
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(receiver.lastEvent)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
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

    // ── PEER STATUS MENU ───────────────────────────────────────────────
    private var peerStatusMenu: some View {
        Menu {
            Section(header: Text("Mesh Actions")) {
                Button(action: { receiver.clearOrders() }) {
                    Label("Clear Orders", systemImage: "trash")
                }
                Button(action: { receiver.restartMesh() }) {
                    Label("Restart Mesh", systemImage: "arrow.triangle.2.circlepath")
                }
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(receiver.connectedCustomerNames.isEmpty ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 11, weight: .semibold))
                Text(receiver.connectedCustomerNames.isEmpty ? "No peers" : "\(receiver.connectedCustomerNames.count) peer\(receiver.connectedCustomerNames.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(receiver.connectedCustomerNames.isEmpty ? .orange : .green)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                receiver.connectedCustomerNames.isEmpty
                    ? Color.orange.opacity(0.1)
                    : Color.green.opacity(0.1)
            )
            .clipShape(Capsule())
        }
    }

    // ── EMPTY STATE ────────────────────────────────────────────────────
    private var emptyState: some View {
        VStack(spacing: 40) {
            Spacer()
            
            if receiver.connectedCustomerNames.isEmpty {
                SpinningLoaderView(tintColor: zomatoRed)
            } else {
                Image(systemName: "bell.slash")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                Text(receiver.connectedCustomerNames.isEmpty
                     ? "Waiting for customer app to connect…"
                     : "Customer app connected. Place an order to see it appear here.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if !receiver.connectedCustomerNames.isEmpty {
                    VStack(spacing: 8) {
                        Text("CONNECTED DEVICES")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .tracking(1)
                        ForEach(receiver.connectedCustomerNames, id: \.self) { name in
                            HStack(spacing: 6) {
                                Circle().fill(Color.green).frame(width: 8, height: 8)
                                Text(name)
                                    .font(.subheadline.weight(.medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Capsule())
                        }
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

// MARK: - Animations

enum RotationDegrees {
    case initialCicle
    case middleCircle
    case initialSmallCircle
    case middleSmallCircle
    case last

    func getRotationDegrees() -> Angle {
        switch self {
        case .initialCicle: return .degrees(365)
        case .initialSmallCircle: return .degrees(679)
        case .middleCircle: return .degrees(375)
        case .middleSmallCircle: return .degrees(825)
        case .last: return .degrees(990)
        }
    }
}

struct SpinningLoaderView: View {
    var tintColor: Color = .blue
    
    @State private var circleEnd: CGFloat = 0.001
    @State private var rotationDegree: Angle = .degrees(-90)
    
    @State private var smallerCircleEnd: CGFloat = 1
    @State private var smallerRotationDegree: Angle = .degrees(-30)
    
    private let animationDuration: Double = 1.35
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: circleEnd)
                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .foregroundColor(tintColor)
                .rotationEffect(rotationDegree)
                .frame(width: 130, height: 130)

            Circle()
                .trim(from: 0, to: smallerCircleEnd)
                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .foregroundColor(tintColor.opacity(0.7))
                .rotationEffect(smallerRotationDegree)
                .frame(width: 48, height: 48)
        }
        .onAppear {
            animate()
            Timer.scheduledTimer(withTimeInterval: animationDuration * 1.98, repeats: true) { _ in
                reset()
                animate()
            }
        }
    }
    
    func animate() {
        withAnimation(.easeOut(duration: animationDuration)) {
            circleEnd = 1
        }
        withAnimation(.easeOut(duration: animationDuration * 1.1)) {
            rotationDegree = RotationDegrees.initialCicle.getRotationDegrees()
        }
        withAnimation(.easeOut(duration: animationDuration * 0.85)) {
            smallerCircleEnd = 0.001
            smallerRotationDegree = RotationDegrees.initialSmallCircle.getRotationDegrees()
        }
        Timer.scheduledTimer(withTimeInterval: animationDuration * 0.7, repeats: false) { _ in
            withAnimation(.easeIn(duration: animationDuration * 0.4)) {
                smallerRotationDegree = RotationDegrees.middleSmallCircle.getRotationDegrees()
                rotationDegree = RotationDegrees.middleCircle.getRotationDegrees()
            }
        }
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            withAnimation(.easeOut(duration: animationDuration)) {
                rotationDegree = RotationDegrees.last.getRotationDegrees()
                circleEnd = 0.001
            }
            withAnimation(.linear(duration: animationDuration * 0.8)) {
                smallerCircleEnd = 1
                smallerRotationDegree = RotationDegrees.last.getRotationDegrees()
            }
        }
    }
    
    func reset() {
        rotationDegree = .degrees(-90)
        smallerRotationDegree = .degrees(-30)
    }
}
