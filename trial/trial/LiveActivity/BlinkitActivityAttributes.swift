//
//  BlinkitActivityAttributes.swift
//  BlinkitFlow
//
//  ActivityKit Live Activity attributes used by OrderLiveActivityWidget.
//

import ActivityKit
import Foundation

public struct BlinkitActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Order tracking state
        public var stageName: String?
        public var etaMinutes: Int?
        public var riderName: String?
        public var progress: Double?
        
        // Cart live activity state
        public var isCart: Bool
        public var cartItemCount: Int?
        public var cartTotalAmount: Double?
        
        public init(
            stageName: String? = nil,
            etaMinutes: Int? = nil,
            riderName: String? = nil,
            progress: Double? = nil,
            isCart: Bool = false,
            cartItemCount: Int? = nil,
            cartTotalAmount: Double? = nil
        ) {
            self.stageName = stageName
            self.etaMinutes = etaMinutes
            self.riderName = riderName
            self.progress = progress
            self.isCart = isCart
            self.cartItemCount = cartItemCount
            self.cartTotalAmount = cartTotalAmount
        }
    }
    
    public var activityId: String
    public var deliveryAddress: String
    
    public init(activityId: String, deliveryAddress: String) {
        self.activityId = activityId
        self.deliveryAddress = deliveryAddress
    }
}
