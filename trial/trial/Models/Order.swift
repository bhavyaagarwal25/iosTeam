//
//  Order.swift
//  BlinkitFlow
//

import Foundation

public enum OrderStage: String, CaseIterable, Codable, Identifiable {
    case placed = "Order Placed"
    case packed = "Packed"
    case riderAssigned = "Rider Assigned"
    case onTheWay = "On the way"
    case delivered = "Delivered"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .placed: return "checkmark.circle.fill"
        case .packed: return "shippingbox.fill"
        case .riderAssigned: return "person.badge.shield.checkmark.fill"
        case .onTheWay: return "bolt.car.fill"
        case .delivered: return "house.circle.fill"
        }
    }
    
    public var progressValue: Double {
        switch self {
        case .placed: return 0.2
        case .packed: return 0.4
        case .riderAssigned: return 0.6
        case .onTheWay: return 0.85
        case .delivered: return 1.0
        }
    }
}

public struct Order: Identifiable, Codable, Hashable {
    public let id: String
    public let items: [CartItem]
    public let totalAmount: Double
    public var stage: OrderStage
    public let orderDate: Date
    public var estimatedDeliveryMinutes: Int
    public let riderName: String
    public let riderPhone: String
    public let deliveryAddress: String
    public let paymentMethod: String
    
    public init(
        id: String = "BLK-" + String(Int.random(in: 100000...999999)),
        items: [CartItem],
        totalAmount: Double,
        stage: OrderStage = .placed,
        orderDate: Date = Date(),
        estimatedDeliveryMinutes: Int = 10,
        riderName: String = "Ramesh Kumar",
        riderPhone: String = "+91 98765 43210",
        deliveryAddress: String = "Flat 402, Sunshine Heights, Koramangala, Bengaluru",
        paymentMethod: String = "Blinkit Pay (UPI)"
    ) {
        self.id = id
        self.items = items
        self.totalAmount = totalAmount
        self.stage = stage
        self.orderDate = orderDate
        self.estimatedDeliveryMinutes = estimatedDeliveryMinutes
        self.riderName = riderName
        self.riderPhone = riderPhone
        self.deliveryAddress = deliveryAddress
        self.paymentMethod = paymentMethod
    }
}
