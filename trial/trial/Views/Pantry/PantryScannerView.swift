//
//  PantryScannerView.swift
//  Blinkit Home Inventory AI
//
//  UI Interface for Pantry Scan:
//  Camera Preview -> Capture Image -> Scanning Laser Animation -> Vision Detection -> Merged Home Inventory.
//

import SwiftUI

@MainActor
public struct PantryScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scannerService = PantryScannerService.shared
    @StateObject private var inventoryManager = InventoryManager.shared
    
    @State private var scanLaserOffset: CGFloat = -140
    @State private var isShowingResults: Bool = false
    @State private var autoCartMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Top Header Info
                    headerSection
                    
                    // Main Camera Viewport & Animation Box
                    cameraViewportSection
                    
                    // Action controls based on scan stage
                    actionControlsSection
                    
                    // Merged Inventory Result Sheet / List
                    if isShowingResults, let snapshot = scannerService.latestPantrySnapshot {
                        resultsSummaryView(snapshot: snapshot)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Pantry AI Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    .foregroundColor(BlinkitTheme.brandGreen)
                Text("Smart Fridge IoT: Online")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(BlinkitTheme.brandGreen)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(BlinkitTheme.brandGreenLight)
            .cornerRadius(12)
            
            Text("Point camera at pantry shelf to scan items")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var cameraViewportSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .darkGray).opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(BlinkitTheme.brandGreen.opacity(0.6), lineWidth: 2)
                )
                .frame(height: 320)
                .padding(.horizontal, 20)
            
            if let image = scannerService.lastCapturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 316)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 22)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 64))
                        .foregroundColor(.white.opacity(0.7))
                    Text("Ready to Capture")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Scanning Laser Overlay Animation
            if case .scanningAnimation = scannerService.currentStage {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, BlinkitTheme.brandGreen, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 8)
                    .shadow(color: BlinkitTheme.brandGreen, radius: 10)
                    .offset(y: scanLaserOffset)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            scanLaserOffset = 140
                        }
                    }
            }
            
            // Stage Status Badge Overlay
            statusBadgeOverlay
        }
    }
    
    @ViewBuilder
    private var statusBadgeOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                switch scannerService.currentStage {
                case .idle:
                    Text("Tap Capture")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                case .cameraActive, .capturing:
                    HStack(spacing: 6) {
                        ProgressView()
                            .tint(.white)
                        Text("Capturing...")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                case .scanningAnimation(let progress):
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(BlinkitTheme.yellow)
                        Text("Scanning Vision AI (\(Int(progress * 100))%)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlinkitTheme.brandGreen)
                    .cornerRadius(10)
                case .analyzingVision:
                    HStack(spacing: 6) {
                        ProgressView()
                            .tint(.white)
                        Text("Apple Vision + CoreML Object Detection")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .cornerRadius(10)
                case .completed:
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Scan & Merged Complete!")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlinkitTheme.brandGreen)
                    .cornerRadius(10)
                case .failed(let msg):
                    Text("Error: \(msg)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(32)
        }
    }
    
    private var actionControlsSection: some View {
        VStack(spacing: 12) {
            if scannerService.currentStage == .idle {
                Button(action: {
                    Task {
                        await scannerService.startScanPipeline()
                        if let snapshot = scannerService.latestPantrySnapshot {
                            await inventoryManager.processFullInventoryScan(pantrySnapshot: snapshot)
                            isShowingResults = true
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Capture Image & Scan Pantry")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(BlinkitTheme.brandGreen)
                    .cornerRadius(16)
                    .shadow(color: BlinkitTheme.brandGreen.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
            } else if case .completed = scannerService.currentStage {
                Button(action: {
                    inventoryManager.syncLowAndMissingToCart()
                    autoCartMessage = "Low & Missing items added to Cart!"
                    BlinkitTheme.triggerNotificationHaptic(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("Automatically Update Cart")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(BlinkitTheme.textPrimaryLight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(BlinkitTheme.yellow)
                    .cornerRadius(16)
                    .shadow(color: BlinkitTheme.yellow.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
            }
            
            if let msg = autoCartMessage {
                Text(msg)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BlinkitTheme.brandGreen)
            }
        }
    }
    
    private func resultsSummaryView(snapshot: InventorySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Home Inventory Status (Merged)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(inventoryManager.items.filter { $0.isLowOrMissing }.count) Needs Reorder")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(inventoryManager.items) { item in
                        VStack(spacing: 4) {
                            Text(item.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Qty: \(item.currentQuantity)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text(item.status.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(item.status == .available ? .green : (item.status == .low ? .orange : .red))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .padding(10)
                        .background(Color(uiColor: .darkGray).opacity(0.6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.5))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
