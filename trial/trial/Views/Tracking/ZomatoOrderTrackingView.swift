//
//  ZomatoOrderTrackingView.swift
//  trial
//

import SwiftUI

public struct ZomatoOrderTrackingView: View {
    @StateObject private var viewModel = ZomatoOrderTrackingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            if let order = viewModel.activeOrder {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Map Placeholder
                        mapPlaceholder
                            .frame(height: 250)
                        
                        // Status Card
                        VStack(spacing: 0) {
                            statusHeader(order: order)
                            
                            Divider().padding(.vertical, 16)
                            
                            // Timeline
                            timelineView
                            
                            Divider().padding(.vertical, 16)
                            
                            // Rider Info
                            if viewModel.currentStageIndex >= 2 { // Picked up or later
                                riderInfo(order: order)
                            } else {
                                restaurantInfo(order: order)
                            }
                            
                            Divider().padding(.vertical, 16)
                            
                            // Order Summary
                            orderSummary(order: order)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                        .offset(y: -24)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .padding(10)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                        .foregroundColor(.primary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Help") {}
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .foregroundColor(.primary)
                    }
                }
            } else {
                emptyState
            }
        }
    }
    
    // MARK: - Map
    private var mapPlaceholder: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96)
            
            // Grid lines to look like a map
            Path { path in
                for i in stride(from: 0, to: 400, by: 40) {
                    path.move(to: CGPoint(x: CGFloat(i), y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i), y: 400))
                    path.move(to: CGPoint(x: 0, y: CGFloat(i)))
                    path.addLine(to: CGPoint(x: 400, y: CGFloat(i)))
                }
            }
            .stroke(Color.white, lineWidth: 2)
            
            // Route line if out for delivery
            if viewModel.currentStageIndex >= 2 {
                Path { path in
                    path.move(to: CGPoint(x: 100, y: 100))
                    path.addCurve(to: CGPoint(x: 200, y: 150), control1: CGPoint(x: 150, y: 80), control2: CGPoint(x: 180, y: 150))
                }
                .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 8]))
                
                // Rider pin
                Image(systemName: "bicycle")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.blue))
                    .position(x: 150, y: 120)
            }
            
            // Destination pin
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 10, height: 4)
            }
            .position(x: 200, y: 150)
        }
    }
    
    // MARK: - Header
    private func statusHeader(order: ZomatoOrder) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.stage.rawValue)
                    .font(.system(size: 24, weight: .heavy))
                Text(order.stage.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if !viewModel.isDelivered {
                VStack(spacing: 2) {
                    Text("\(viewModel.etaCountdown)")
                        .font(.system(size: 28, weight: .bold))
                    Text("mins")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Timeline
    private var timelineView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.stages.enumerated()), id: \.element) { index, stage in
                let isCompleted = index <= viewModel.currentStageIndex
                let isCurrent = index == viewModel.currentStageIndex
                
                HStack(alignment: .top, spacing: 16) {
                    // Icon + Line
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
                                .frame(width: 24, height: 24)
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if index < viewModel.stages.count - 1 {
                            Rectangle()
                                .fill(index < viewModel.currentStageIndex ? Color.green : Color.gray.opacity(0.2))
                                .frame(width: 2, height: 30)
                        }
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stage.rawValue)
                            .font(.system(size: 15, weight: isCurrent ? .bold : .medium))
                            .foregroundColor(isCompleted ? .primary : .secondary)
                        
                        if isCurrent {
                            Text(stage.subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, index < viewModel.stages.count - 1 ? 20 : 0)
                }
            }
        }
    }
    
    // MARK: - Rider / Restaurant Info
    private func riderInfo(order: ZomatoOrder) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(order.riderName)
                    .font(.system(size: 16, weight: .bold))
                HStack(spacing: 4) {
                    Text("Delivery Partner")
                    Text("•")
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 10))
                    Text("4.8")
                }
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
                Button(action: {}) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func restaurantInfo(order: ZomatoOrder) -> some View {
        HStack(spacing: 12) {
            let r = ZomatoDataService.shared.restaurant(for: order.restaurantId)
            Image(r?.imageName ?? "pizza")
                .resizable().aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40).cornerRadius(8).clipped()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(order.restaurantName)
                    .font(.system(size: 16, weight: .bold))
                Text("Preparing your order")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Order Summary
    private func orderSummary(order: ZomatoOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Details").font(.system(size: 16, weight: .bold))
            
            Text("Order #\(order.id)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            ForEach(order.items) { item in
                HStack(alignment: .top) {
                    Text("\(item.quantity)×")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 24, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.menuItem.name).font(.system(size: 14))
                        if !item.customizationSummary.isEmpty {
                            Text(item.customizationSummary)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            
            Divider().padding(.vertical, 8)
            
            HStack {
                Text("Total Paid").font(.system(size: 14, weight: .bold))
                Spacer()
                Text("₹\(Int(order.grandTotal))").font(.system(size: 14, weight: .bold))
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag").font(.system(size: 50)).foregroundColor(.gray.opacity(0.3))
            Text("No active orders").font(.system(size: 20, weight: .bold))
            Text("Looks like you haven't placed an order yet.")
                .font(.system(size: 14)).foregroundColor(.secondary)
        }
    }
}
