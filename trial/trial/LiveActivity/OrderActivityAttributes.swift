//
//  OrderActivityAttributes.swift
//  BlinkitFlow
//
//  DEMO: Live Activity & Dynamic Island data structures.
//

import ActivityKit
import Foundation

public struct OrderActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var stageName: String
        public var etaMinutes: Int
        public var riderName: String
        public var progress: Double
        
        public init(stageName: String, etaMinutes: Int, riderName: String, progress: Double) {
            self.stageName = stageName
            self.etaMinutes = etaMinutes
            self.riderName = riderName
            self.progress = progress
        }
    }
    
    public var orderId: String
    public var itemCount: Int
    
    public init(orderId: String, itemCount: Int) {
        self.orderId = orderId
        self.itemCount = itemCount
    }
}
