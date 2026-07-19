//
//  DebugOverlay.swift
//  Eternal Lite — Demo Instrumentation
//
//  PURPOSE: A floating debug pill that shows real-time stats during the demo:
//  - API calls made this session (the KEY metric)
//  - Current mode (Lite vs Rich)
//  - Cache status (HIT/MISS)
//  - Connection type (WiFi/Cellular/Offline)
//
//  This is what makes the demo VISUAL. Judges can see the counter increment
//  in real time and compare Traditional (47 calls) vs Eternal Lite (1 call).
//

import SwiftUI

public struct DebugOverlay: View {
    @ObservedObject var apiService: EternalLiteAPIService
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var cacheService: LiteCacheService
    @State private var isExpanded: Bool = false
    
    public init(
        apiService: EternalLiteAPIService = .shared,
        networkMonitor: NetworkMonitor = .shared,
        cacheService: LiteCacheService = .shared
    ) {
        self.apiService = apiService
        self.networkMonitor = networkMonitor
        self.cacheService = cacheService
    }
    
    public var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Compact pill (always visible)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    // API Call counter — the HERO metric
                    HStack(spacing: 3) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(apiService.apiCallCount)")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(apiService.apiCallCount <= 2 ? .green : (apiService.apiCallCount <= 10 ? .yellow : .red))
                    
                    // Connection type indicator
                    Circle()
                        .fill(connectionColor)
                        .frame(width: 6, height: 6)
                    
                    // Mode indicator
                    Text(networkMonitor.isLiteMode ? "⚡" : "🖼")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
            }
            
            // Expanded detail panel
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // API Calls
                    debugRow(
                        icon: "antenna.radiowaves.left.and.right",
                        label: "API Calls",
                        value: "\(apiService.apiCallCount)",
                        valueColor: apiService.apiCallCount <= 2 ? .green : .red
                    )
                    
                    // Mode
                    debugRow(
                        icon: networkMonitor.isLiteMode ? "bolt.fill" : "photo.fill",
                        label: "Mode",
                        value: networkMonitor.isLiteMode ? "Lite ⚡" : "Rich 🖼",
                        valueColor: networkMonitor.isLiteMode ? .yellow : .blue
                    )
                    
                    // Cache
                    debugRow(
                        icon: "cylinder.split.1x2",
                        label: "Cache",
                        value: cacheService.lastCacheResult,
                        valueColor: cacheService.lastCacheResult.contains("HIT") ? .green : .orange
                    )
                    
                    // Connection
                    debugRow(
                        icon: "wifi",
                        label: "Network",
                        value: networkMonitor.connectionType.rawValue,
                        valueColor: connectionColor
                    )
                    
                    // Cache stats
                    HStack(spacing: 8) {
                        Text("Hits: \(cacheService.cacheHitCount)")
                            .foregroundColor(.green)
                        Text("Misses: \(cacheService.cacheMissCount)")
                            .foregroundColor(.red)
                    }
                    .font(.system(size: 9, design: .monospaced))
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    // Action buttons
                    HStack(spacing: 8) {
                        Button("Reset Counter") {
                            apiService.resetCounter()
                            cacheService.resetCounters()
                        }
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Clear Cache") {
                            cacheService.clearAll()
                        }
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange)
                    }
                    

                }
                .padding(12)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                .frame(width: 200)
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var connectionColor: Color {
        switch networkMonitor.connectionType {
        case .wifi: return .green
        case .cellular: return .yellow
        case .wiredEthernet: return .blue
        case .unknown: return .gray
        case .none: return .red
        }
    }
    
    private func debugRow(icon: String, label: String, value: String, valueColor: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(.gray)
                .frame(width: 14)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(valueColor)
        }
    }
}
