//
//  ContentView.swift
//  BlinkitFlow
//
//  Main container view with tab bar navigation and deep link handler.
//

import SwiftUI

@MainActor
public struct ContentView: View {
    @StateObject private var cartService = CartService.shared
    @StateObject private var orderService = OrderService.shared
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home (Figma: home 1, x:30)
            HomeView(onRedirectToCart: {
                selectedTab = 1
            })
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Tab 2: Cart/Shopping bag (Figma: shopping-bag 1, x:117)
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "bag.fill")
                }
                .badge(cartService.totalItemCount > 0 ? cartService.totalItemCount : 0)
                .tag(1)

            // Tab 3: Category (Figma: category 1, x:203)
            CategoryView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)

            // Tab 4: Printer (Figma: printer 1, x:293)
            PrintStoreView()
                .tabItem {
                    Label("Print", systemImage: "printer.fill")
                }
                .tag(3)
        }
        .tint(Color(red: 0.1, green: 0.57, blue: 0.25))
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
        }
        .onOpenURL { url in
            // Deep link handler (e.g. from Widget or Siri)
            if url.host == "reorder" {
                if let savedList = MockData.savedLists.first {
                    cartService.addSavedListToCart(savedList)
                    selectedTab = 2 // Navigate to cart tab
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
