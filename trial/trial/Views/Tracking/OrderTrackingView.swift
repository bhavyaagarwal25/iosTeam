//
//  OrderTrackingView.swift
//  BlinkitFlow
//

import SwiftUI
import MapKit

@MainActor
public struct OrderTrackingView: View {
    @StateObject private var viewModel: OrderTrackingViewModel
    
    // Map region centered on Koramangala Bengaluru
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    public init() {
        _viewModel = StateObject(wrappedValue: OrderTrackingViewModel())
    }
    
    public init(viewModel: OrderTrackingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if let order = viewModel.activeOrder {
                    // ETA Header Banner
                    etaHeaderCard(order: order)
                    
                    // Map visualizer preview
                    mapVisualizerCard
                    
                    // Stage Progression Stepper
                    stageProgressCard(order: order)
                    
                    // Rider Detail Card
                    riderDetailCard(order: order)
                    
                    // Demo Manual Stage Advance Button
                    manualAdvanceButton
                } else {
                    noActiveOrderView
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Track Live Order")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func etaHeaderCard(order: Order) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(order.stage == .delivered ? "ORDER DELIVERED 🎉" : "ARRIVING IN \(order.estimatedDeliveryMinutes) MINS")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(order.stage == .delivered ? .white : BlinkitTheme.textPrimaryLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(order.stage == .delivered ? BlinkitTheme.brandGreen : BlinkitTheme.yellow)
                    .cornerRadius(6)
                Spacer()
                Text("ID: \(order.id)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: order.stage.progressValue)
                .accentColor(BlinkitTheme.brandGreen)
                .scaleEffect(x: 1, y: 2.5, anchor: .center)
                .padding(.vertical, 8)
            
            Text("Order placed at \(order.orderDate.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var mapVisualizerCard: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $position) {
                Marker("Blinkit Dark Store", coordinate: CLLocationCoordinate2D(latitude: 12.9360, longitude: 77.6250))
                    .tint(.black)
                Marker("Rider Ramesh", coordinate: CLLocationCoordinate2D(latitude: 12.9355, longitude: 77.6247))
                    .tint(BlinkitTheme.brandGreen)
                Marker("Delivery Address", coordinate: CLLocationCoordinate2D(latitude: 12.9340, longitude: 77.6235))
                    .tint(.red)
            }
            .frame(height: 180)
            .cornerRadius(16)
            
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("LIVE GPS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.7))
            .cornerRadius(6)
            .padding(10)
        }
        .padding(.horizontal, 16)
    }
    
    private func stageProgressCard(order: Order) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Order Status")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 12) {
                ForEach(OrderStage.allCases) { stage in
                    let isCurrent = order.stage == stage
                    let isPast = stage.progressValue <= order.stage.progressValue
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isPast ? BlinkitTheme.brandGreen : Color(uiColor: .tertiarySystemBackground))
                                .frame(width: 32, height: 32)
                            Image(systemName: stage.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(isPast ? .white : .secondary)
                        }
                        
                        Text(stage.rawValue)
                            .font(.system(size: 14, weight: isCurrent ? .bold : .medium))
                            .foregroundColor(isCurrent ? BlinkitTheme.brandGreen : (isPast ? .primary : .secondary))
                        
                        Spacer()
                        
                        if isCurrent {
                            Text("IN PROGRESS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(BlinkitTheme.brandGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(BlinkitTheme.brandGreenLight)
                                .cornerRadius(4)
                        } else if isPast {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(BlinkitTheme.brandGreen)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    private func riderDetailCard(order: Order) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(BlinkitTheme.brandGreenLight)
                    .frame(width: 44, height: 44)
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .foregroundColor(BlinkitTheme.brandGreen)
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(order.riderName)
                    .font(.system(size: 15, weight: .bold))
                Text("Assigned Store Rider • 4.9 ★")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                BlinkitTheme.triggerHaptic(.medium)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "phone.fill")
                    Text("Call")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(BlinkitTheme.brandGreen)
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var manualAdvanceButton: some View {
        Button(action: {
            viewModel.manualAdvanceStage()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.horizontal.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("Simulate Next Order Stage 🚀")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(BlinkitTheme.textPrimaryLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(BlinkitTheme.yellow)
            .cornerRadius(14)
            .shadow(color: BlinkitTheme.yellow.opacity(0.4), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
        }
    }
    
    private var noActiveOrderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Active Order")
                .font(.system(size: 18, weight: .bold))
            Text("Place an order to track store packing and rider delivery live.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }
}
