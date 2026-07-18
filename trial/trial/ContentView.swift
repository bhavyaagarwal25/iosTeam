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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
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
        .tint(BlinkitTheme.brandGreen)
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
