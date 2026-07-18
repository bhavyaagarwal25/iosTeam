//
//  ProfileView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    
    public init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel())
    }
    
    public init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // User Header Card
                profileHeaderCard
                
                // "Running Low" Smart Nudges
                runningLowCard
                
                // Past Orders List with 1-Tap Reorder
                pastOrdersCard
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Profile & Orders")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var profileHeaderCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(BlinkitTheme.brandGreen)
                    .frame(width: 50, height: 50)
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bhavya Agarwal")
                    .font(.system(size: 16, weight: .bold))
                Text("+91 98765 43210 • Pro Member")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("VIP")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(BlinkitTheme.textPrimaryLight)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(BlinkitTheme.yellow)
                .cornerRadius(6)
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var runningLowCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                Text("Running Low (Smart Nudges)")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
            }
            
            Text("Based on your order frequency, you might be running low on these items:")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(viewModel.runningLowProducts) { product in
                    HStack {
                        Image(systemName: product.systemImage)
                            .foregroundColor(BlinkitTheme.brandGreen)
                            .frame(width: 28, height: 28)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(product.name)
                                .font(.system(size: 13, weight: .semibold))
                            Text("Ordered 3 days ago")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.reorderSingleProduct(product)
                        }) {
                            Text("Reorder Now")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(BlinkitTheme.brandGreen)
                                .cornerRadius(8)
                        }
                    }
                    .padding(10)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                }
            }
            
            // Notification Demo Trigger
            Button(action: {
                viewModel.scheduleRunningLowNotification()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 12))
                    Text(viewModel.notificationScheduled ? "Notification Scheduled in 3s!" : "Schedule Local Notification Demo")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(BlinkitTheme.brandGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(BlinkitTheme.brandGreenLight)
                .cornerRadius(10)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var pastOrdersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Orders")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ForEach(viewModel.pastOrders) { order in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(order.id)
                                    .font(.system(size: 13, weight: .bold))
                                Text(order.orderDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(order.stage.rawValue.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(BlinkitTheme.brandGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(BlinkitTheme.brandGreenLight)
                                .cornerRadius(6)
                        }
                        
                        Divider()
                        
                        ForEach(order.items) { item in
                            HStack {
                                Text("\(item.quantity)x \(item.product.name)")
                                    .font(.system(size: 13))
                                Spacer()
                                Text("₹\(Int(item.totalCost))")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total: ₹\(Int(order.totalAmount))")
                                .font(.system(size: 14, weight: .bold))
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.reorderOrder(order)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("1-Tap Reorder")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(BlinkitTheme.brandGreen)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
