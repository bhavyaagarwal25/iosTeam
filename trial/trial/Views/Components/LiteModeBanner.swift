//
//  LiteModeBanner.swift
//  Eternal Lite — Lite Mode Indicator
//
//  PURPOSE: A subtle, dismissible banner shown at the top of the screen when
//  Lite Mode is active. Includes a manual toggle to override automatic detection.
//
//  DESIGN: Matches iOS system banner aesthetics — compact, translucent,
//  with a lightning bolt icon and toggle switch.
//

import SwiftUI

public struct LiteModeBanner: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    @State private var isExpanded: Bool = false
    
    public init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
    }
    
    public var body: some View {
        if networkMonitor.isLiteMode {
            VStack(spacing: 0) {
                // Main banner
                HStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Lite Mode Active")
                            .font(.system(size: 12, weight: .bold))
                        Text(statusText)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Expand/collapse for toggle
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                // Expanded section with toggle
                if isExpanded {
                    Divider().background(Color.white.opacity(0.2))
                    
                    HStack {
                        Text("Auto (based on network)")
                            .font(.system(size: 11))
                        
                        Spacer()
                        
                        // Manual override toggle
                        Toggle("", isOn: Binding(
                            get: { networkMonitor.userOverrideLiteMode ?? networkMonitor.isLiteMode },
                            set: { newValue in
                                if newValue == networkMonitor.isLiteMode && networkMonitor.userOverrideLiteMode != nil {
                                    // Tapping back to auto state → clear override
                                    networkMonitor.userOverrideLiteMode = nil
                                } else {
                                    networkMonitor.userOverrideLiteMode = newValue
                                }
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .yellow))
                        .scaleEffect(0.8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    
                    if networkMonitor.userOverrideLiteMode != nil {
                        Text("Manual override active · tap toggle to return to auto")
                            .font(.system(size: 9))
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                    }
                }
            }
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.7))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private var statusText: String {
        if !networkMonitor.isConnected { return "No network · using cached data" }
        if networkMonitor.isConstrained { return "Low Data Mode · saving bandwidth" }
        if networkMonitor.isExpensive { return "Cellular · text-only menu" }
        if networkMonitor.userOverrideLiteMode == true { return "Manual override · forced on" }
        return "Active"
    }
}
