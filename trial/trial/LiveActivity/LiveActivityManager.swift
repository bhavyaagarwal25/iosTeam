//
//  LiveActivityManager.swift
//  BlinkitFlow
//

import Foundation
import ActivityKit
import Combine
import SwiftUI

@MainActor
public class LiveActivityManager: ObservableObject {
    public static let shared = LiveActivityManager()
    
    private var cartActivity: Activity<BlinkitActivityAttributes>? = nil
    
    public init() {}
    
    public func startCartActivity(itemCount: Int, totalAmount: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let existing = Activity<BlinkitActivityAttributes>.activities.first(where: { $0.content.state.isCart })
        if let existing = existing {
            cartActivity = existing
            updateCartActivity(itemCount: itemCount, totalAmount: totalAmount)
            return
        }
        
        let attributes = BlinkitActivityAttributes(activityId: "cart_\(UUID().uuidString)")
        let state = BlinkitActivityAttributes.ContentState(
            cartTotalAmount: totalAmount,
            cartItemCount: itemCount
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        do {
            cartActivity = try Activity.request(attributes: attributes, content: content)
            print("Started Cart Live Activity: \(cartActivity?.id ?? "")")
        } catch {
            print("Failed to start Cart Live Activity: \(error)")
        }
    }
    
    public func updateCartActivity(itemCount: Int, totalAmount: Double) {
        guard let activity = cartActivity else { return }
        let state = BlinkitActivityAttributes.ContentState(
            cartTotalAmount: totalAmount,
            cartItemCount: itemCount
        )
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    public func stopCartActivity() {
        let activities = Activity<BlinkitActivityAttributes>.activities.filter { $0.content.state.isCart }
        for activity in activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        self.cartActivity = nil
    }
}
