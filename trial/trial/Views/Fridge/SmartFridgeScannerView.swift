//
//  SmartFridgeScannerView.swift
//  Blinkit Home Inventory AI
//
//  Dedicated UI for Smart Fridge IoT inventory scanning:
//  User's uploaded fridge photo -> Laser sweep animation -> IoT JSON fetch -> Auto-add low/missing items -> Redirect to Cart.
//

import SwiftUI

@MainActor
public struct SmartFridgeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var inventoryManager = InventoryManager.shared
    
    public var onRedirectToCart: (() -> Void)? = nil
    
    @State private var isScanning: Bool = false
    @State private var scanProgress: Double = 0.0
    @State private var laserOffset: CGFloat = -150
    @State private var scanCompleted: Bool = false
    @State private var detectedFridgeSnapshot: InventorySnapshot? = nil
    @State private var autoCartMessage: String? = nil
    @State private var detectedLowItems: [InventoryItem] = []
    
    public init(onRedirectToCart: (() -> Void)? = nil) {
        self.onRedirectToCart = onRedirectToCart
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // IoT Status Header
                    iotHeaderCard
                    
                    // Smart Fridge Viewport using User's Uploaded Fridge Photo
                    fridgePhotoViewportCard
                    
                    // Action Scan Button
                    scanActionButton
                    
                    // Detected Items List & Auto Cart Status
                    if scanCompleted, let snapshot = detectedFridgeSnapshot {
                        detectedFridgeItemsList(snapshot: snapshot)
                    }
                    
                    Spacer()
                }
                .padding(.top, 12)
            }
            .navigationTitle("Smart Fridge IoT AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(BlinkitTheme.brandGreen)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var iotHeaderCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: "snowflake")
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Samsung IoT Smart Fridge")
                        .font(.system(size: 15, weight: .bold))
                    Text("ONLINE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
                Text("Sensors connected • Auto-inventory tracking")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var fridgePhotoViewportCard: some View {
        ZStack {
            // Refrigerator Image Container (User Uploaded Photo Asset)
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.85))
                .frame(height: 330)
                .padding(.horizontal, 16)
            
            Image("fridge_interior")
                .resizable()
                .scaledToFit()
                .frame(height: 320)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                )
                .padding(.horizontal, 20)
            
            // Floating Dynamic Item Badges Overlay
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    fridgeItemOverlayBadge(name: "milk", icon: "drop.fill")
                    fridgeItemOverlayBadge(name: "butter", icon: "square.fill")
                    fridgeItemOverlayBadge(name: "cheese", icon: "cube.fill")
                }
                
                HStack(spacing: 16) {
                    fridgeItemOverlayBadge(name: "icecream", icon: "snowflake")
                    fridgeItemOverlayBadge(name: "dahi", icon: "cup.and.saucer.fill")
                    fridgeItemOverlayBadge(name: "eggs", icon: "circle.grid.2x2.fill")
                }
            }
            
            // Scanning Laser Sweep Animation Line
            if isScanning {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.blue, Color.cyan, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 8)
                    .shadow(color: Color.blue, radius: 12)
                    .offset(y: laserOffset)
                    .padding(.horizontal, 24)
            }
            
            // Scanning Progress & Live Item Detection List Overlay
            if isScanning {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Scanning Fridge... (\(Int(scanProgress * 100))%)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(12)
                    
                    // Live lists of detected low items being added to cart
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🚨 Low / Missing Items to Add:")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 2)
                        
                        let itemsToShow = Int(scanProgress * Double(detectedLowItems.count))
                        ForEach(0..<itemsToShow, id: \.self) { index in
                            let item = detectedLowItems[index]
                            let status = item.status == .low ? "Low ⚠️" : "Missing ❌"
                            liveItemRow(name: item.name.capitalized, status: status)
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(12)
                    .frame(width: 250)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func liveItemRow(name: String, status: String) -> some View {
        HStack {
            Text("• \(name)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text(status)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.yellow)
        }
    }
    
    private func fridgeItemOverlayBadge(name: String, icon: String) -> some View {
        let item = inventoryManager.items.first(where: { $0.name.lowercased() == name.lowercased() })
        let qty = item?.currentQuantity ?? 0
        let status = item?.status ?? .missing
        
        let color: Color
        switch status {
        case .available: color = .green
        case .low: color = .orange
        case .missing: color = .red
        }
        
        return HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text("\(name): \(qty)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.75))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: 1)
        )
    }
    
    private var scanActionButton: some View {
        Button(action: {
            performFridgeIoTScan()
        }) {
            HStack(spacing: 8) {
                Image(systemName: isScanning ? "arrow.triangle.2.circlepath" : "snowflake")
                    .font(.system(size: 18, weight: .bold))
                Text(isScanning ? "Scanning Fridge..." : "Scan Fridge & Redirect to Cart")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isScanning ? Color.gray : Color.blue)
            .cornerRadius(16)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
        }
        .disabled(isScanning)
    }
    
    private func detectedFridgeItemsList(snapshot: InventorySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if detectedLowItems.isEmpty {
                // ✅ Everything is stocked!
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 42))
                        .foregroundColor(BlinkitTheme.brandGreen)
                    
                    Text("Fridge is Fully Stocked! 🎉")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("All your items are at healthy levels.\nNo restocking needed right now.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Show all stocked items in a compact grid
                    let stockedItems = inventoryManager.items.filter { item in
                        snapshot.itemQuantities.keys.contains(item.name.lowercased())
                    }
                    
                    if !stockedItems.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(stockedItems) { item in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(BlinkitTheme.brandGreen)
                                        .font(.system(size: 12))
                                    Text(item.name.capitalized)
                                        .font(.system(size: 13, weight: .medium))
                                    Spacer()
                                    Text("Qty: \(item.currentQuantity)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                // Items were added to cart
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BlinkitTheme.brandGreen)
                    Text("Fridge IoT Scan Complete!")
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                }
                
                if let msg = autoCartMessage {
                    Text(msg)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(BlinkitTheme.brandGreen)
                        .padding(.vertical, 2)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(BlinkitTheme.brandGreen.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Scan Execution & Auto Cart Redirection
    
    private func performFridgeIoTScan() {
        isScanning = true
        scanCompleted = false
        scanProgress = 0.0
        laserOffset = -150
        detectedLowItems = []
        
        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            laserOffset = 150
        }
        
        Task {
            // Fetch snapshot FIRST so we can show accurate dynamic items during animation
            let iotSnapshot = try await MockIoTService.shared.fetchSmartFridgeSnapshot()
            
            // Determine which items from the snapshot are actually low/missing
            let snapshotKeys = Set(iotSnapshot.itemQuantities.keys.map { $0.lowercased() })
            
            self.detectedLowItems = inventoryManager.items.filter { item in
                if snapshotKeys.contains(item.name.lowercased()) {
                    let qty = iotSnapshot.itemQuantities[item.name.lowercased()] ?? 0
                    return qty < item.minimumThreshold
                }
                return false
            }
            
            // Run fake animation sweep
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 150_000_000)
                scanProgress = Double(i) / 10.0
            }
            
            await inventoryManager.processFullInventoryScan(pantrySnapshot: iotSnapshot)
            
            // Clear existing cart items first so ONLY fridge-scanned low/missing items are present
            CartService.shared.clearCart()
            
            // Sync ONLY fridge-detected low/missing items — must pass iotSnapshot to filter
            inventoryManager.syncLowAndMissingToCart(from: iotSnapshot)
            let countAfter = CartService.shared.items.count
            
            self.detectedFridgeSnapshot = iotSnapshot
            self.isScanning = false
            self.scanCompleted = true
            
            if countAfter > 0 {
                self.autoCartMessage = "🛒 \(countAfter) low & missing fridge items added! Redirecting to Cart..."
                BlinkitTheme.triggerNotificationHaptic(.success)
                
                // Auto Redirect to Cart after 1.2 second delay
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                dismiss()
                
                // Allow sheet to dismiss before triggering tab switch
                try? await Task.sleep(nanoseconds: 500_000_000)
                onRedirectToCart?()
            } else {
                // All items are stocked — no need to go to cart
                self.autoCartMessage = nil  // clear any old message
                BlinkitTheme.triggerNotificationHaptic(.success)
                // Stay on screen and show the "all good" card — user can tap Done to close
            }
        }
    }
}
