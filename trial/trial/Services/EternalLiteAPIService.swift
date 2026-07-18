//
//  EternalLiteAPIService.swift
//  Eternal Lite — Batched API Layer
//
//  PURPOSE: Demonstrates the core "Eternal Lite" optimization — replacing 5+
//  separate API calls with ONE batched fetch. Includes a visible API call counter
//  for the live demo.
//
//  TRADITIONAL MODE (what most food apps do):
//    fetchRestaurants()  → API call #1 (menu data)
//    fetchCart()          → API call #2 (cart state)
//    fetchDeliveryFee()   → API call #3 (fee calculation)
//    fetchOffers()        → API call #4 (coupons/offers)
//    fetchAddresses()     → API call #5 (saved addresses)
//    Total: 5 calls × ~200ms each = ~1000ms latency on cellular
//
//  ETERNAL LITE MODE (our optimization):
//    fetchAggregatedData() → API call #1 (EVERYTHING in one payload)
//    Total: 1 call × ~200ms = ~200ms latency
//
//  APPLE API: Foundation (URLSession patterns, though mocked locally)
//

import Foundation
import Combine

@MainActor
public final class EternalLiteAPIService: ObservableObject {
    public static let shared = EternalLiteAPIService()
    
    // MARK: - Published State
    
    /// Total API calls made this session — THE key metric for the demo
    @Published public var apiCallCount: Int = 0
    
    /// Whether we're currently in "traditional" (many calls) or "lite" (batched) mode
    @Published public var isUsingBatchedMode: Bool = true
    
    /// Last fetch timestamp
    @Published public var lastFetchTime: Date? = nil
    
    /// Whether a fetch is in progress
    @Published public var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let cache = LiteCacheService.shared
    private let networkMonitor = NetworkMonitor.shared
    
    private static let cacheKey = "aggregated_payload"
    private static let cacheMaxAge: TimeInterval = 300 // 5 minutes
    
    private init() {}
    
    // MARK: - ⚡ ETERNAL LITE: Single Batched Fetch (1 API call)
    
    /// Fetches ALL data needed for the home screen in ONE call.
    /// This is the core optimization: 1 call instead of 5+.
    ///
    /// Flow:
    /// 1. Check local cache → if fresh, return immediately (0 calls)
    /// 2. If stale/missing, make 1 aggregated "API call" (simulated)
    /// 3. Cache the result for next time
    ///
    /// In production, this would be: GET /api/v1/aggregated?lat=X&lng=Y
    public func fetchAggregatedData() async -> AggregatedPayload {
        isLoading = true
        defer { isLoading = false }
        
        // Step 1: Check cache
        let cacheResult = cache.loadWithFreshness(
            key: Self.cacheKey,
            type: AggregatedPayload.self,
            maxAge: Self.cacheMaxAge
        )
        
        switch cacheResult {
        case .hit(let payload, _):
            // Cache is fresh — ZERO API calls needed!
            #if DEBUG
            print("⚡ EternalLiteAPI: Cache HIT — 0 API calls needed")
            #endif
            return payload
            
        case .stale(let stalePayload, _):
            // Cache exists but is stale — fetch in background, return stale immediately
            // This gives instant UI while refreshing
            #if DEBUG
            print("⚡ EternalLiteAPI: Cache STALE — returning stale data + background refresh")
            #endif
            Task { @MainActor in
                let fresh = await self.performAggregatedFetch()
                self.cache.cache(key: Self.cacheKey, data: fresh)
            }
            return stalePayload
            
        case .miss:
            // No cache — must fetch
            #if DEBUG
            print("⚡ EternalLiteAPI: Cache MISS — fetching aggregated data")
            #endif
            let payload = await performAggregatedFetch()
            cache.cache(key: Self.cacheKey, data: payload)
            return payload
        }
    }
    
    /// The actual "API call" — simulates network delay and returns mock data.
    /// In production this would be a real URLSession.shared.data(from:) call.
    private func performAggregatedFetch() async -> AggregatedPayload {
        // INCREMENT COUNTER: This is the 1 API call
        apiCallCount += 1
        lastFetchTime = Date()
        
        // Simulate network delay based on connection quality
        let delay = networkMonitor.simulatedDelay
        try? await Task.sleep(for: .seconds(delay))
        
        return Self.buildMockPayload()
    }
    
    // MARK: - 🐌 TRADITIONAL: Separate Fetches (5+ API calls)
    // These methods exist ONLY to demonstrate the "before" state in the demo.
    // Each one increments the API counter separately.
    
    /// Traditional: Fetch restaurants separately (API call #1)
    public func fetchRestaurants() async -> [LiteRestaurant] {
        apiCallCount += 1
        try? await Task.sleep(for: .seconds(networkMonitor.simulatedDelay))
        return Self.buildMockPayload().restaurants
    }
    
    /// Traditional: Fetch cart separately (API call #2)
    public func fetchCart() async -> LiteCartState {
        apiCallCount += 1
        try? await Task.sleep(for: .seconds(networkMonitor.simulatedDelay))
        return Self.buildMockPayload().cart
    }
    
    /// Traditional: Fetch delivery fee separately (API call #3)
    public func fetchDeliveryFee() async -> LiteDeliveryFee {
        apiCallCount += 1
        try? await Task.sleep(for: .seconds(networkMonitor.simulatedDelay))
        return Self.buildMockPayload().deliveryFee
    }
    
    /// Traditional: Fetch offers separately (API call #4)
    public func fetchOffers() async -> [LiteOffer] {
        apiCallCount += 1
        try? await Task.sleep(for: .seconds(networkMonitor.simulatedDelay))
        return Self.buildMockPayload().offers
    }
    
    /// Traditional: Fetch addresses separately (API call #5)
    public func fetchAddresses() async -> [LiteAddress] {
        apiCallCount += 1
        try? await Task.sleep(for: .seconds(networkMonitor.simulatedDelay))
        return Self.buildMockPayload().addresses
    }
    
    // MARK: - Traditional polling for order tracking (to contrast with Live Activity)
    
    /// Traditional: Poll order status every 5 seconds (each poll = 1 API call)
    /// In Eternal Lite mode, this is replaced by ActivityKit push updates (0 calls).
    public func pollOrderStatus() {
        apiCallCount += 1
        #if DEBUG
        print("🐌 Traditional: Polled order status — total calls now: \(apiCallCount)")
        #endif
    }
    
    // MARK: - Counter Management
    
    /// Reset the API call counter (for demo: "let's start fresh and compare")
    public func resetCounter() {
        apiCallCount = 0
        lastFetchTime = nil
    }
    
    // MARK: - Mock Data Builder
    
    /// Builds a realistic mock AggregatedPayload from existing Zomato mock data.
    /// In production, the server would assemble this from its databases.
    private static func buildMockPayload() -> AggregatedPayload {
        // Convert existing Restaurant models to lightweight LiteRestaurant
        let restaurants = MockZomatoData.restaurants.map { r -> LiteRestaurant in
            let timeStr = r.deliveryTime.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let distStr = r.distance.replacingOccurrences(of: " km", with: "").trimmingCharacters(in: .whitespaces)
            
            let menuItems = r.menuItems.map { item -> LiteMenuItem in
                LiteMenuItem(
                    id: item.id,
                    name: item.name,
                    price: item.price,
                    isVeg: item.isVeg,
                    isBestseller: item.isBestseller,
                    section: item.menuSection
                )
            }
            
            return LiteRestaurant(
                id: r.id,
                name: r.name,
                cuisine: r.cuisineText,
                rating: r.rating,
                ratingCount: r.numberOfRatings,
                deliveryTimeMin: Int(timeStr) ?? 30,
                distanceKm: Double(distStr) ?? 2.0,
                priceForTwo: r.priceForTwo,
                isVeg: r.isPureVeg,
                isOpen: r.isOpen,
                offer: r.offer,
                menuItems: menuItems
            )
        }
        
        let offers = MockZomatoData.coupons.map { c -> LiteOffer in
            LiteOffer(id: c.id, code: c.code, title: c.title, minOrder: c.minOrderAmount)
        }
        
        let addresses = MockZomatoData.addresses.map { a -> LiteAddress in
            LiteAddress(id: a.id, label: a.label, address: a.fullAddress)
        }
        
        return AggregatedPayload(
            restaurants: restaurants,
            cart: LiteCartState(),
            deliveryFee: LiteDeliveryFee(),
            offers: offers,
            addresses: addresses,
            serverTimestamp: Date(),
            etag: "v\(Int(Date().timeIntervalSince1970))"
        )
    }
}
