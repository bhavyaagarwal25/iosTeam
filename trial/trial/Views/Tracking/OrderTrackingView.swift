//
//  OrderTrackingView.swift
//  BlinkitFlow
//

import SwiftUI
import MapKit

@MainActor
public struct OrderTrackingView: View {
    @StateObject private var viewModel: OrderTrackingViewModel
    @State private var selectedPlayerForGame: NearbyPlayer? = nil
    
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
        ZStack(alignment: .top) {
            // Full Screen Map
            mapVisualizerCard
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if let order = viewModel.activeOrder {
                    // ETA Header Banner at the top
                    etaHeaderCard(order: order)
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    // Rider Detail Card at the bottom
                    riderDetailCard(order: order)
                        .padding(.bottom, 16)
                } else {
                    Spacer()
                    noActiveOrderView
                        .background(Color(uiColor: .systemBackground).opacity(0.9))
                        .cornerRadius(16)
                        .padding(16)
                    Spacer()
                }
            }
        }
        .navigationTitle("Track Live Order")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedPlayerForGame) { player in
            HandCricketView(opponentName: player.name) {
                selectedPlayerForGame = nil
            }
        }
    }
    
    private func etaHeaderCard(order: Order) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(order.stage == .delivered ? "ORDER DELIVERED 🎉" : "ARRIVING IN \(order.estimatedDeliveryMinutes) MINS")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(order.stage == .delivered ? .white : BlinkitTheme.textPrimaryLight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(order.stage == .delivered ? BlinkitTheme.brandGreen : BlinkitTheme.yellow)
                    .clipShape(Capsule())
                Spacer()
                Text("ID: \(order.id)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    Capsule()
                        .fill(BlinkitTheme.brandGreen)
                        .frame(width: max(0, geometry.size.width * CGFloat(order.stage.progressValue)), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.vertical, 6)
            
            Text("Order placed at \(order.orderDate.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
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
                
                ForEach(viewModel.nearbyPlayers) { player in
                    Annotation(player.name, coordinate: player.coordinate) {
                        Button(action: {
                            selectedPlayerForGame = player
                        }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 32, height: 32)
                                        .shadow(radius: 2)
                                    Image(systemName: "figure.cricket")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                                Text("Play")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                            }
                        }
                    }
                }
            }
            
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
            .padding(.top, 140) // Move below the header
            .padding(.trailing, 16)
        }
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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .foregroundColor(BlinkitTheme.brandGreen)
                    .font(.system(size: 26))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.riderName)
                    .font(.system(size: 16, weight: .bold))
                Text("Assigned Store Rider • 4.9 ★")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                BlinkitTheme.triggerHaptic(.medium)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Call")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(BlinkitTheme.brandGreen)
                .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.8))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
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
