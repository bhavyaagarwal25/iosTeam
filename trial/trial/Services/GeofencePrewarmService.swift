//
//  GeofencePrewarmService.swift
//  Eternal Lite — Geofenced Pre-Warming (Stretch Goal)
//
//  PURPOSE: Pre-fetches and caches the user's likely menu/order data when
//  they enter a familiar location (home, office, gym), BEFORE they open the app.
//
//  APPLE API: CoreLocation → CLMonitor (iOS 17+ async/await API)
//  - Uses CLMonitor.CircularGeographicCondition for region monitoring
//  - Stays under Apple's 20-region monitoring limit (we use only 3)
//  - Not using the older delegate-based CLLocationManager
//
//  HACKATHON ANGLE: The app "knows" you're at home and pre-loads your
//  usual restaurants before you even open it. When you do open — instant load.
//

import Foundation
import CoreLocation
import Combine

/// Represents a monitored location for pre-warming
public struct PrewarmRegion: Identifiable, Codable {
    public let id: String
    public let label: String            // "Home", "Office", "Gym"
    public let latitude: Double
    public let longitude: Double
    public let radiusMeters: Double     // Typically 100-200m
    
    public init(id: String = UUID().uuidString, label: String, latitude: Double, longitude: Double, radiusMeters: Double = 150) {
        self.id = id
        self.label = label
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
    }
}

@MainActor
public final class GeofencePrewarmService: ObservableObject {
    public static let shared = GeofencePrewarmService()
    
    // MARK: - Published State
    
    /// Currently monitored regions (max 3 for our use case, well under Apple's 20 limit)
    @Published public private(set) var monitoredRegions: [PrewarmRegion] = []
    
    /// The last region the user entered (for debug display)
    @Published public var lastTriggeredRegion: String? = nil
    
    /// Whether pre-warming is active
    @Published public var isPrewarmingEnabled: Bool = true
    
    // MARK: - Private
    
    private let apiService = EternalLiteAPIService.shared
    private let cacheService = LiteCacheService.shared
    
    /// Mock regions for demo — in production these come from the user's saved addresses
    private static let mockRegions: [PrewarmRegion] = [
        PrewarmRegion(label: "Home", latitude: 28.6139, longitude: 77.2090, radiusMeters: 150),
        PrewarmRegion(label: "Office", latitude: 28.6280, longitude: 77.2197, radiusMeters: 200),
        PrewarmRegion(label: "Gym", latitude: 28.6100, longitude: 77.2300, radiusMeters: 100)
    ]
    
    private init() {
        monitoredRegions = Self.mockRegions
    }
    
    // MARK: - Region Monitoring
    
    /// Start monitoring all pre-warm regions using CLMonitor (iOS 17+).
    ///
    /// CLMonitor is Apple's modern async/await replacement for the older
    /// CLLocationManager delegate-based region monitoring. It provides:
    /// - Simpler async/await API
    /// - Better battery efficiency
    /// - Automatic persistence across app launches
    ///
    /// NOTE: For the hackathon demo, we simulate the region entry instead
    /// of requiring actual GPS movement. The code structure matches exactly
    /// what the production version would look like.
    @available(iOS 17.0, *)
    public func startMonitoring() async {
        guard isPrewarmingEnabled else { return }
        
        // In production, this would create a CLMonitor and add conditions:
        //
        //   let monitor = await CLMonitor("com.eternallite.prewarm")
        //   for region in monitoredRegions {
        //       let condition = CLMonitor.CircularGeographicCondition(
        //           center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude),
        //           radius: region.radiusMeters
        //       )
        //       await monitor.add(condition, identifier: region.id)
        //   }
        //
        //   // Then observe events asynchronously:
        //   for try await event in await monitor.events {
        //       if event.state == .satisfied {
        //           // User entered the region — pre-warm cache!
        //           await prewarmForRegion(event.identifier)
        //       }
        //   }
        
        #if DEBUG
        print("📍 GeofencePrewarm: Monitoring \(monitoredRegions.count) regions (under Apple's 20-region limit)")
        for region in monitoredRegions {
            print("   → \(region.label): (\(region.latitude), \(region.longitude)) r=\(region.radiusMeters)m")
        }
        #endif
    }
    
    // MARK: - Pre-Warming
    
    /// Called when user enters a monitored region.
    /// Silently pre-fetches and caches their likely menu data.
    public func prewarmForRegion(_ regionId: String) async {
        guard let region = monitoredRegions.first(where: { $0.id == regionId }) else { return }
        
        lastTriggeredRegion = region.label
        
        #if DEBUG
        print("🔥 GeofencePrewarm: User entered '\(region.label)' — pre-warming cache...")
        #endif
        
        // Fetch and cache the aggregated data in the background
        // When the user opens the app, it'll be an instant cache HIT
        let _ = await apiService.fetchAggregatedData()
        
        #if DEBUG
        print("✅ GeofencePrewarm: Cache pre-warmed for '\(region.label)' — next app open will be instant!")
        #endif
    }
    
    /// Simulate a region entry for demo purposes.
    /// Judges can tap this to see the pre-warming in action.
    public func simulateRegionEntry(label: String) async {
        guard let region = monitoredRegions.first(where: { $0.label == label }) else { return }
        await prewarmForRegion(region.id)
    }
}
