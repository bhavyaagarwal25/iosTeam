//
//  LiveActivityManager.swift
//  BlinkitFlow + Eternal Lite
//
//  ETERNAL LITE ADDITION: Order Tracking via Live Activity
//
//  PURPOSE: Instead of polling the server every 5 seconds for order status
//  (which adds 12 API calls/minute × 30 min delivery = 360 calls per order!),
//  we use ActivityKit Live Activities that receive PUSH updates.
//
//  APPLE API: ActivityKit → Activity<T>.request() / .update() / .end()
//
//  PRODUCTION NOTE: In a real app, order status updates would arrive via
//  APNs push notifications targeting the Live Activity's pushToken.
//  The server sends a push ONLY when status actually changes (5 times per order),
//  not on a polling interval. This means:
//    - Traditional polling: ~360 API calls per order
//    - Live Activity push:  ~5 pushes per order (0 client-initiated calls)
//
//  For this hackathon demo, we simulate the push updates with a local Timer,
//  but the architecture is identical to the production APNs flow.
//

import Foundation
import ActivityKit
import Combine
import SwiftUI

@MainActor
public class LiveActivityManager: ObservableObject {
    public static let shared = LiveActivityManager()
    
    private var cartActivity: Activity<BlinkitActivityAttributes>? = nil
    private var orderActivity: Activity<BlinkitActivityAttributes>? = nil
    private var orderStageTimer: Timer? = nil
    
    public init() {}
    
    // MARK: - Cart Live Activity (existing)
    
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
    
    // MARK: - 🆕 Order Tracking Live Activity (Eternal Lite)
    //
    // This replaces the traditional polling approach:
    //   TRADITIONAL: Timer fires every 5s → GET /order/status → 360 calls per 30-min delivery
    //   ETERNAL LITE: Server pushes 5 updates via APNs → 0 client-initiated calls
    //
    // We simulate the APNs pushes with a local timer, but in production:
    //   1. On order placement, server creates a Live Activity push target
    //   2. When order status changes, server sends an APNs push to the activity's pushToken
    //   3. iOS updates the Dynamic Island and Lock Screen widget automatically
    //   4. The app does NOT need to be open — zero foreground polling
    
    /// Start a Live Activity for order tracking. Called when an order is placed.
    public func startOrderTrackingActivity(
        stageName: String,
        etaMinutes: Int,
        riderName: String,
        progress: Double
    ) {
        // End any existing cart activity first
        stopCartActivity()
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities not enabled")
            return
        }
        
        let attributes = BlinkitActivityAttributes(
            activityId: "order_\(UUID().uuidString)",
            deliveryAddress: "Flat 402, Sunshine Heights"
        )
        
        let state = BlinkitActivityAttributes.ContentState(
            stageName: stageName,
            etaMinutes: etaMinutes,
            riderName: riderName,
            progress: progress
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        do {
            orderActivity = try Activity.request(attributes: attributes, content: content)
            print("🟢 Started Order Tracking Live Activity: \(orderActivity?.id ?? "")")
            
            // PRODUCTION NOTE:
            // Here we would register the activity's pushToken with our backend:
            //   if let pushToken = orderActivity?.pushToken {
            //       await backendService.registerLiveActivityToken(orderId: orderId, token: pushToken)
            //   }
            // Then the server sends APNs pushes to update the activity.
            // For this demo, we use a local timer instead.
            
        } catch {
            print("❌ Failed to start Order Tracking Live Activity: \(error)")
        }
    }
    
    /// Update the order tracking Live Activity with new stage info.
    /// In production: this would be triggered by an incoming APNs push, NOT a timer.
    public func updateOrderStage(
        stageName: String,
        etaMinutes: Int,
        riderName: String,
        progress: Double
    ) {
        guard let activity = orderActivity else { return }
        
        let state = BlinkitActivityAttributes.ContentState(
            stageName: stageName,
            etaMinutes: etaMinutes,
            riderName: riderName,
            progress: progress
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            await activity.update(content)
            print("📍 Updated Live Activity: \(stageName) — ETA \(etaMinutes)min — Progress \(Int(progress * 100))%")
        }
    }
    
    /// End the order tracking Live Activity (order delivered or cancelled).
    public func stopOrderTrackingActivity() {
        if let activity = orderActivity {
            Task {
                let finalState = BlinkitActivityAttributes.ContentState(
                    stageName: "Delivered",
                    etaMinutes: 0,
                    riderName: "Vikram Singh",
                    progress: 1.0
                )
                let content = ActivityContent(state: finalState, staleDate: nil)
                await activity.end(content, dismissalPolicy: .after(.now + 300)) // Show for 5 min after delivery
            }
        }
        orderActivity = nil
        orderStageTimer?.invalidate()
        orderStageTimer = nil
    }
}

