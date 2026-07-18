//
//  OrderService.swift
//  BlinkitFlow
//

import Foundation
import UIKit
import Combine
import ActivityKit

@MainActor
public class OrderService: ObservableObject {
    public static let shared = OrderService()
    
    @Published public var activeOrder: Order? = nil
    @Published public var pastOrders: [Order] = MockData.mockPastOrders
    
    private var currentActivity: Activity<OrderActivityAttributes>? = nil
    private var stageTimer: Timer?
    
    public init() {}
    
    // DEMO: Live Activity starts here
    public func placeOrder(items: [CartItem], totalAmount: Double, address: String, paymentMethod: String) -> Order {
        let newOrder = Order(
            items: items,
            totalAmount: totalAmount,
            stage: .placed,
            orderDate: Date(),
            estimatedDeliveryMinutes: 10,
            riderName: "Ramesh Kumar",
            riderPhone: "+91 98765 43210",
            deliveryAddress: address,
            paymentMethod: paymentMethod
        )
        
        self.activeOrder = newOrder
        self.pastOrders.insert(newOrder, at: 0)
        
        // Request real ActivityKit Live Activity for Dynamic Island
        startLiveActivity(for: newOrder)
        
        // Start Live Activity simulation timer
        startOrderStageSimulation()
        
        BlinkitTheme.triggerNotificationHaptic(.success)
        return newOrder
    }
    
    public func reorderPastOrder(_ order: Order, cartService: CartService = CartService.shared) {
        for item in order.items {
            cartService.addToCart(product: item.product, quantity: item.quantity, user: MockData.currentUser)
        }
        BlinkitTheme.triggerNotificationHaptic(.success)
    }
    
    public func advanceOrderStage() {
        guard var order = activeOrder else { return }
        switch order.stage {
        case .placed:
            order.stage = .packed
            order.estimatedDeliveryMinutes = 8
        case .packed:
            order.stage = .riderAssigned
            order.estimatedDeliveryMinutes = 6
        case .riderAssigned:
            order.stage = .onTheWay
            order.estimatedDeliveryMinutes = 3
        case .onTheWay:
            order.stage = .delivered
            order.estimatedDeliveryMinutes = 0
            stageTimer?.invalidate()
            stageTimer = nil
        case .delivered:
            break
        }
        self.activeOrder = order
        
        // Update past orders list matching ID
        if let idx = pastOrders.firstIndex(where: { $0.id == order.id }) {
            pastOrders[idx] = order
        }
        
        // Update ActivityKit Dynamic Island state
        updateLiveActivity(for: order)
        
        BlinkitTheme.triggerHaptic(.medium)
    }
    
    private func startLiveActivity(for order: Order) {
        let isEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
        print("Live Activity check - Are Activities Enabled: \(isEnabled)")
        
        guard isEnabled else {
            print("WARNING: Live Activities are currently disabled on this iOS device or in Settings!")
            return
        }
        
        let attributes = OrderActivityAttributes(orderId: order.id, itemCount: order.items.count)
        let initialState = OrderActivityAttributes.ContentState(
            stageName: order.stage.rawValue,
            etaMinutes: order.estimatedDeliveryMinutes,
            riderName: order.riderName,
            progress: order.stage.progressValue
        )
        
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("SUCCESS: Live Activity requested with ID: \(currentActivity?.id ?? "unknown")")
        } catch {
            print("ERROR requesting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity(for order: Order) {
        guard let activity = currentActivity else { return }
        let updatedState = OrderActivityAttributes.ContentState(
            stageName: order.stage.rawValue,
            etaMinutes: order.estimatedDeliveryMinutes,
            riderName: order.riderName,
            progress: order.stage.progressValue
        )
        
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(content)
            if order.stage == .delivered {
                await activity.end(content, dismissalPolicy: .after(Date().addingTimeInterval(5)))
                self.currentActivity = nil
            }
        }
    }
    
    private func startOrderStageSimulation() {
        stageTimer?.invalidate()
        stageTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let current = self.activeOrder else { return }
                if current.stage != .delivered {
                    self.advanceOrderStage()
                } else {
                    self.stageTimer?.invalidate()
                    self.stageTimer = nil
                }
            }
        }
    }
}
