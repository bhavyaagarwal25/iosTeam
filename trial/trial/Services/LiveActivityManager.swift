//
//  LiveActivityManager.swift
//  BlinkitFlow
//
//  Manages cart and order Live Activities for the Dynamic Island.
//

import ActivityKit
import Foundation

@MainActor
public final class LiveActivityManager {
    public static let shared = LiveActivityManager()
    
    private var cartActivity: Activity<BlinkitActivityAttributes>? = nil
    
    private init() {}
    
    public func startCartActivity(itemCount: Int, totalAmount: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = BlinkitActivityAttributes(activityId: "cart-\(UUID().uuidString)", deliveryAddress: "")
        let state = BlinkitActivityAttributes.ContentState(
            isCart: true,
            cartItemCount: itemCount,
            cartTotalAmount: totalAmount
        )
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            do {
                self.cartActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
            } catch {
                print("LiveActivityManager: Failed to start cart activity: \(error)")
            }
        }
    }
    
    public func updateCartActivity(itemCount: Int, totalAmount: Double) {
        guard let activity = cartActivity else {
            startCartActivity(itemCount: itemCount, totalAmount: totalAmount)
            return
        }
        
        let updatedState = BlinkitActivityAttributes.ContentState(
            isCart: true,
            cartItemCount: itemCount,
            cartTotalAmount: totalAmount
        )
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    public func stopCartActivity() {
        Task {
            let finalState = BlinkitActivityAttributes.ContentState(isCart: true, cartItemCount: 0, cartTotalAmount: 0)
            let content = ActivityContent(state: finalState, staleDate: nil)
            await cartActivity?.end(content, dismissalPolicy: .immediate)
            self.cartActivity = nil
        }
    }
}
