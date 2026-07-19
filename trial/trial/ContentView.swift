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
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if isZomatoMode {
                // Zomato Mode (Handles its own views & Zomato floating capsule tab bar)
                ZomatoHomeView()
            } else {
                // Blinkit Mode Navigation
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                        
                    SearchView()
                        .tabItem {
                            Label("Categories", systemImage: "square.grid.2x2.fill")
                        }
                        .tag(1)
                        
                    CartView()
                        .tabItem {
                            Label("Cart", systemImage: "cart.fill")
                        }
                        .badge(cartService.totalItemCount > 0 ? cartService.totalItemCount : 0)
                        .tag(2)
                        
                    OrderTrackingView()
                        .tabItem {
                            Label("Track", systemImage: "bolt.car.fill")
                        }
                        .badge(orderService.activeOrder != nil && orderService.activeOrder?.stage != .delivered ? "LIVE" : nil)
                        .tag(3)
                        
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(4)
                }
                .tint(Color(red: 0.05, green: 0.52, blue: 0.12)) // Blinkit brand green
            }
            
            // App Switcher Floating Pill (Top/Side Toggle)
            appSwitcherButton
                .padding(.trailing, 16)
                .padding(.bottom, 160)
        }
        // 🆕 ETERNAL LITE: Overlay debug tools and lite mode banner
        .overlay(alignment: .top) {
            if isZomatoMode {
                LiteModeBanner(networkMonitor: networkMonitor)
                    .padding(.top, 50)
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
    }
    
    // MARK: - App Switcher Button (2-mode: Customer/Zomato)
    private var appSwitcherButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isZomatoMode.toggle()
                        selectedTab = 0
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isZomatoMode ? "cart.fill" : "fork.knife")
                        Text(isZomatoMode ? "Blinkit" : "Zomato")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(isZomatoMode ? Color(red: 0.05, green: 0.52, blue: 0.12) : Color(red: 0.9, green: 0.1, blue: 0.2))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}

