//
//  ZomatoOrderService.swift
//  trial
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
        
        startStageSimulation()
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
        BlinkitTheme.triggerHaptic(.medium)
    }
    
    private func startStageSimulation() {
        stageTimer?.invalidate()
        stageTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let current = self.activeOrder else { return }
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
    }
}
