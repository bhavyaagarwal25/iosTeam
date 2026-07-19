//
//  ContentView.swift
//  BlinkitFlow
//
//  Main container view with custom floating capsule tab bar for both Blinkit & Zomato modes.
//

import SwiftUI

@MainActor
public struct ContentView: View {
    @StateObject private var cartService = CartService.shared
    @StateObject private var orderService = OrderService.shared
    
    // 🆕 ETERNAL LITE: Network monitoring and API instrumentation
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var apiService = EternalLiteAPIService.shared
    @StateObject private var cacheService = LiteCacheService.shared

    // 🆕 MESH RELAY: Singletons kept alive for the app's lifetime
    @StateObject private var meshRelay   = MeshRelayService.shared
    @StateObject private var meshUpload  = MeshUploadService.shared
    @StateObject private var meshStatus  = MeshOrderStatusManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var isZomatoMode: Bool = false
    @State private var isRestaurantMode: Bool = false
    @State private var showProofScreen: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if isRestaurantMode {
                // Restaurant Dashboard Mode (receives orders via mesh)
                RestaurantDashboardView()
            } else if isZomatoMode {
                // Zomato Mode (Handles its own views & Zomato floating capsule tab bar)
                ZomatoHomeView()
            } else {
                // Blinkit Mode Navigation
                ZStack(alignment: .bottom) {
                    Group {
                        switch selectedTab {
                        case 0: HomeView()
                        case 1: SearchView()
                        case 2: CartView()
                        case 3: OrderTrackingView()
                        case 4: ProfileView()
                        default: HomeView()
                        }
                    }
                    
                    // Floating Capsule Tab Bar for Blinkit (Matching User Screenshot)
                    CustomBlinkitTabBar(
                        selectedTab: $selectedTab,
                        cartService: cartService,
                        orderService: orderService
                    )
                }
            }
            
            // App Switcher Floating Pill (Top/Side Toggle)
            appSwitcherButton
                .padding(.trailing, 16)
                .padding(.bottom, 90)
        }
        // 🆕 ETERNAL LITE: Overlay debug tools and lite mode banner
        .overlay(alignment: .top) {
            if isZomatoMode {
                LiteModeBanner(networkMonitor: networkMonitor)
                    .padding(.top, 50)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isZomatoMode {
                // Single unified demo console replaces two separate overlays
                DemoConsole()
                    .padding(.top, 56)
                    .padding(.trailing, 12)
            }
        }
        // 🆕 MESH RELAY: Show order status badge above the tab bar when active
        .overlay(alignment: .bottom) {
            if let latest = meshStatus.latestEntry, !latest.status.isTerminal {
                MeshStatusBadge()
                    .padding(.bottom, 90)
            }
        }
        .onAppear {
            // Nuke ALL stale persisted data on every launch — ensures clean state for demo
            let keysToWipe = [
                "blinkit_mock_iot_telemetry_v2",
                "blinkit_home_inventory_v1",
                "blinkit_cart_items_v1",
                "blinkit_last_scan_snapshot_v1",
                "blinkit_last_order_v1"
            ]
            keysToWipe.forEach { UserDefaults.standard.removeObject(forKey: $0) }

            // 🆕 MESH RELAY: Start advertising + browsing immediately on launch
            // Pre-warming the mesh means peers are already discovered by the time
            // the user places an order — no latency penalty at order time.
            meshRelay.start()
        }
        .onOpenURL { url in
            if url.host == "reorder" {
                if let savedList = MockData.savedLists.first {
                    cartService.addSavedListToCart(savedList)
                    isZomatoMode = false
                    selectedTab = 2
                }
            }
        }
        .sheet(isPresented: $showProofScreen) {
            ProofScreen()
        }
    }
    
    // MARK: - App Switcher Button (3-mode: Customer/Zomato/Restaurant + Proof Screen)
    private var appSwitcherButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                // Proof Screen button (only in Zomato mode)
                if isZomatoMode {
                    Button(action: { showProofScreen = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                            Text("Proof")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.purple)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                }
                
                // Mode switcher menu
                Menu {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isZomatoMode = false
                            isRestaurantMode = false
                            selectedTab = 0
                        }
                    }) {
                        Label("Customer (Blinkit)", systemImage: "cart.fill")
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isZomatoMode = true
                            isRestaurantMode = false
                        }
                    }) {
                        Label("Customer (Zomato)", systemImage: "fork.knife")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isRestaurantMode = true
                            isZomatoMode = false
                        }
                    }) {
                        Label("Restaurant Dashboard", systemImage: "storefront.fill")
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: currentModeIcon)
                        Text(currentModeLabel)
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(currentModeColor)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
    
    private var currentModeIcon: String {
        if isRestaurantMode { return "storefront.fill" }
        if isZomatoMode { return "fork.knife" }
        return "cart.fill"
    }
    
    private var currentModeLabel: String {
        if isRestaurantMode { return "Restaurant" }
        if isZomatoMode { return "Zomato" }
        return "Blinkit"
    }
    
    private var currentModeColor: Color {
        if isRestaurantMode { return Color.orange }
        if isZomatoMode { return Color(red: 0.9, green: 0.1, blue: 0.2) }
        return Color(red: 0.05, green: 0.52, blue: 0.12)
    }
}

// MARK: - Custom Floating Capsule Tab Bar for Blinkit (Matches Screenshot)

struct CustomBlinkitTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var cartService: CartService
    @ObservedObject var orderService: OrderService
    
    let tabs: [(title: String, icon: String)] = [
        ("Home", "house.fill"),
        ("Categories", "square.grid.2x2.fill"),
        ("Cart", "cart.fill"),
        ("Track", "bolt.car.fill"),
        ("Profile", "person.fill")
    ]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<tabs.count, id: \.self) { index in
                let isSelected = selectedTab == index
                let tab = tabs[index]
                
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    BlinkitTheme.triggerHaptic(.light)
                }) {
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 3) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                            Text(tab.title)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                        }
                        .foregroundColor(isSelected ? Color(red: 0.05, green: 0.52, blue: 0.12) : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            Group {
                                if isSelected {
                                    Capsule()
                                        .fill(Color(red: 0.9, green: 0.96, blue: 0.92))
                                }
                            }
                        )
                        
                        // Badge count for Cart
                        if index == 2 && cartService.totalItemCount > 0 {
                            Text("\(cartService.totalItemCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: -4, y: -2)
                        }
                        
                        // LIVE badge for Track
                        if index == 3 && orderService.activeOrder != nil && orderService.activeOrder?.stage != .delivered {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .offset(x: -6, y: 2)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 5)
        .overlay(Capsule().stroke(Color.gray.opacity(0.18), lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
