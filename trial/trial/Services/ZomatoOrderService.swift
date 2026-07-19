//
//  ZomatoOrderService.swift
//  trial + Eternal Lite
//
//  ETERNAL LITE INTEGRATION:
//  - On placeOrder(): starts a Live Activity (replaces polling)
//  - On advanceStage(): updates the Live Activity via ActivityKit (simulated push)
//  - Traditional mode: also polls via timer, incrementing API counter each time
//  - Lite mode: zero polling — Live Activity receives "push" updates only
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class ZomatoOrderService: ObservableObject {
    public static let shared = ZomatoOrderService()
    
    @Published public var activeOrder: ZomatoOrder? = nil
    @Published public var pastOrders: [ZomatoOrder] = MockZomatoData.pastOrders
    
    private var stageTimer: Timer?
    
    /// Reference to the API service for incrementing the call counter
    /// when traditional polling is active
    private let apiService = EternalLiteAPIService.shared
    private let liveActivityManager = LiveActivityManager.shared
    private let networkMonitor = NetworkMonitor.shared
    
    /// Tracks whether we're using Live Activity (push) or polling (traditional)
    @Published public var isUsingLiveActivity: Bool = true
    
    /// Counter for polling calls specifically (for demo comparison)
    @Published public var pollingCallCount: Int = 0
    
    public init() {}
    
    public func placeOrder(cartService: ZomatoCartService, address: String, paymentMethod: String) -> ZomatoOrder {
        let order = ZomatoOrder(
            items: cartService.items,
            restaurantName: cartService.currentRestaurantName ?? "Restaurant",
            restaurantId: cartService.currentRestaurantId ?? "",
            itemTotal: cartService.itemTotal,
            deliveryFee: cartService.deliveryFee,
            taxes: cartService.taxes,
            packagingFee: cartService.packagingFee,
            platformFee: cartService.platformFee,
            tip: cartService.tipAmount,
            donation: cartService.donationAmount,
            couponDiscount: cartService.couponDiscount,
            grandTotal: cartService.grandTotal,
            stage: .preparing,
            estimatedMinutes: 30,
            deliveryAddress: address,
            paymentMethod: paymentMethod,
            couponCode: cartService.appliedCoupon?.code
        )
        
        activeOrder = order
        pastOrders.insert(order, at: 0)
        cartService.clearCart()
        
        if networkMonitor.isConnected {
            // ONLINE FLOW: Start Live Activity and simulate normal backend progress
            liveActivityManager.startOrderTrackingActivity(
                stageName: order.stage.rawValue,
                etaMinutes: order.estimatedMinutes,
                riderName: order.riderName,
                progress: order.stage.progressValue
            )
            startStageSimulation()
        } else {
            // OFFLINE FLOW: Enqueue locally and broadcast via Mesh Relay
            OfflineOrderQueue.shared.enqueue(order: order)
        }
        
        BlinkitTheme.triggerNotificationHaptic(.success)
        
        return order
    }
    
    public func advanceStage() {
        guard var order = activeOrder else { return }
        switch order.stage {
        case .preparing:
            order.stage = .cooking
            order.estimatedMinutes = 25
        case .cooking:
            order.stage = .pickedUp
            order.estimatedMinutes = 15
        case .pickedUp:
            order.stage = .nearYou
            order.estimatedMinutes = 5
        case .nearYou:
            order.stage = .delivered
            order.estimatedMinutes = 0
            stageTimer?.invalidate()
            stageTimer = nil
        case .delivered:
            break
        }
        activeOrder = order
        
        if let idx = pastOrders.firstIndex(where: { $0.id == order.id }) {
            pastOrders[idx] = order
        }
        
        // 🆕 ETERNAL LITE: Update Live Activity (simulates APNs push)
        // In production, the server would send this push when the rider's
        // status changes. The app doesn't need to ask — the server tells it.
        if order.stage == .delivered {
            liveActivityManager.stopOrderTrackingActivity()
        } else {
            liveActivityManager.updateOrderStage(
                stageName: order.stage.rawValue,
                etaMinutes: order.estimatedMinutes,
                riderName: order.riderName,
                progress: order.stage.progressValue
            )
        }
        
        BlinkitTheme.triggerHaptic(.medium)
    }
    
    private func startStageSimulation() {
        stageTimer?.invalidate()
        pollingCallCount = 0
        
        // Stage advances every 30 seconds (more realistic than 5s)
        stageTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let current = self.activeOrder else { return }
                
                // TRADITIONAL MODE: Each timer tick = 1 polling API call
                // In a real app without Live Activities, the client would
                // GET /order/{id}/status every 5 seconds, burning through
                // ~360 API calls for a 30-minute delivery.
                if !self.networkMonitor.isLiteMode {
                    self.apiService.pollOrderStatus()
                    self.pollingCallCount += 1
                }
                
                if current.stage != .delivered {
                    self.advanceStage()
                } else {
                    self.stageTimer?.invalidate()
                    self.stageTimer = nil
                }
            }
        }
    }
    
    public func clearActiveOrder() {
        activeOrder = nil
        stageTimer?.invalidate()
        stageTimer = nil
        liveActivityManager.stopOrderTrackingActivity()
    }
}

