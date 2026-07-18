//
//  NetworkMonitor.swift
//  Eternal Lite — Network Awareness Layer
//
//  PURPOSE: Detects network quality using Apple's Network.framework (NWPathMonitor)
//  and automatically triggers "Lite Mode" when the user is on a constrained or
//  expensive connection (Low Data Mode, cellular, or no connectivity).
//
//  APPLE API: Network.framework → NWPathMonitor
//  - path.isConstrained: true when iOS "Low Data Mode" is enabled in Settings
//  - path.isExpensive: true on cellular (metered) connections
//  - path.status: .satisfied / .unsatisfied / .requiresConnection
//
//  HACKATHON ANGLE: This is the FOUNDATION — everything else (batched fetch,
//  caching, offline queue) keys off the network state exposed here.
//

import Foundation
import Network
import Combine

/// Singleton that monitors real-time network conditions using NWPathMonitor.
/// Publishes reactive state that the entire app observes to toggle Lite Mode.
@MainActor
public final class NetworkMonitor: ObservableObject {
    public static let shared = NetworkMonitor()
    
    // MARK: - Published State (drives all UI decisions)
    
    /// True when the device has ANY network path available
    @Published public private(set) var isConnected: Bool = true
    
    /// True when iOS "Low Data Mode" is enabled (Settings → Cellular → Low Data Mode)
    /// Apple API: NWPath.isConstrained
    @Published public private(set) var isConstrained: Bool = false
    
    /// True when on a metered/cellular connection (not Wi-Fi)
    /// Apple API: NWPath.isExpensive
    @Published public private(set) var isExpensive: Bool = false
    
    /// The current interface type: wifi, cellular, wiredEthernet, or none
    @Published public private(set) var connectionType: ConnectionType = .unknown
    
    /// User can manually override Lite Mode:
    /// - nil = automatic (based on network conditions)
    /// - true = force Lite Mode ON
    /// - false = force Lite Mode OFF
    @Published public var userOverrideLiteMode: Bool? = nil
    
    /// The computed Lite Mode state that the ENTIRE app reads.
    /// Automatic: true when constrained OR expensive OR disconnected.
    /// Can be overridden by the user toggle.
    public var isLiteMode: Bool {
        if let override = userOverrideLiteMode {
            return override
        }
        return isConstrained || isExpensive || !isConnected
    }
    
    /// Simulated network delay for mock API calls (longer on bad networks)
    public var simulatedDelay: TimeInterval {
        if !isConnected { return 5.0 }         // Offline — will timeout
        if isConstrained { return 2.0 }          // Low Data Mode — slow
        if isExpensive { return 1.5 }            // Cellular — moderate
        return 0.3                                // Wi-Fi — fast
    }
    
    // MARK: - Private
    
    /// The NWPathMonitor instance — Apple's built-in network observer
    private let monitor = NWPathMonitor()
    
    /// Dedicated serial queue so NWPathMonitor doesn't block the main thread
    private let monitorQueue = DispatchQueue(label: "com.eternallite.networkmonitor", qos: .utility)
    
    public enum ConnectionType: String {
        case wifi = "Wi-Fi"
        case cellular = "Cellular"
        case wiredEthernet = "Ethernet"
        case unknown = "Unknown"
        case none = "Offline"
    }
    
    // MARK: - Init
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    /// Starts NWPathMonitor and maps path updates to our published properties.
    /// This runs on a background queue; we dispatch results to @MainActor.
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                // Map NWPath status to our simplified state
                self.isConnected = (path.status == .satisfied)
                self.isConstrained = path.isConstrained
                self.isExpensive = path.isExpensive
                
                // Determine the primary interface type
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .wiredEthernet
                } else if path.status == .satisfied {
                    self.connectionType = .unknown
                } else {
                    self.connectionType = .none
                }
                
                #if DEBUG
                print("🌐 NetworkMonitor: connected=\(self.isConnected) constrained=\(self.isConstrained) expensive=\(self.isExpensive) type=\(self.connectionType.rawValue) → liteMode=\(self.isLiteMode)")
                #endif
            }
        }
        
        // Start monitoring on a dedicated background queue
        monitor.start(queue: monitorQueue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Demo Helpers
    
    /// Force a specific network state for demo/testing purposes.
    /// Useful when presenting to judges with Network Link Conditioner.
    public func simulateState(connected: Bool, constrained: Bool, expensive: Bool, type: ConnectionType) {
        self.isConnected = connected
        self.isConstrained = constrained
        self.isExpensive = expensive
        self.connectionType = type
    }
}
