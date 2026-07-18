//
//  BlinkitActivityAttributes.swift
//  BlinkitFlow
//
//  Live Activity & Dynamic Island data structures.
//

import ActivityKit
import Foundation

public struct BlinkitActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Shared properties
        public var isCart: Bool
        
        // Cart specific properties
        public var cartTotalAmount: Double?
        public var cartItemCount: Int?
        
        // Order specific properties
        public var stageName: String?
        public var etaMinutes: Int?
        public var riderName: String?
        public var progress: Double?
        
        // Init for Cart Activity
        public init(cartTotalAmount: Double, cartItemCount: Int) {
            self.isCart = true
            self.cartTotalAmount = cartTotalAmount
            self.cartItemCount = cartItemCount
        }
        
        // Init for Order Activity
        public init(stageName: String, etaMinutes: Int, riderName: String, progress: Double) {
            self.isCart = false
            self.stageName = stageName
            self.etaMinutes = etaMinutes
            self.riderName = riderName
            self.progress = progress
        }
    }
    
    // Static attributes
    public var activityId: String
    public var deliveryAddress: String?
    
    public init(activityId: String = UUID().uuidString, deliveryAddress: String? = nil) {
        self.activityId = activityId
        self.deliveryAddress = deliveryAddress
    }
}
