//
//  ZomatoOrder.swift
//  trial
//

import Foundation

public enum ZomatoOrderStage: String, CaseIterable, Codable, Identifiable {
    case preparing = "Preparing"
    case cooking = "Cooking"
    case pickedUp = "Picked Up"
    case nearYou = "Near You"
    case delivered = "Delivered"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .preparing: return "bag.fill"
        case .cooking: return "flame.fill"
        case .pickedUp: return "bicycle"
        case .nearYou: return "location.fill"
        case .delivered: return "checkmark.circle.fill"
        }
    }
    
    public var progressValue: Double {
        switch self {
        case .preparing: return 0.2
        case .cooking: return 0.4
        case .pickedUp: return 0.6
        case .nearYou: return 0.8
        case .delivered: return 1.0
        }
    }
    
    public var subtitle: String {
        switch self {
        case .preparing: return "Restaurant is preparing your order"
        case .cooking: return "Your food is being freshly cooked"
        case .pickedUp: return "Rider has picked up your order"
        case .nearYou: return "Rider is almost at your location"
        case .delivered: return "Order delivered! Enjoy your meal"
        }
    }
}

public struct ZomatoOrder: Identifiable, Codable, Hashable {
    public let id: String
    public let items: [ZomatoCartItem]
    public let restaurantName: String
    public let restaurantId: String
    public let itemTotal: Double
    public let deliveryFee: Double
    public let taxes: Double
    public let packagingFee: Double
    public let platformFee: Double
    public let tip: Double
    public let donation: Double
    public let couponDiscount: Double
    public let grandTotal: Double
    public var stage: ZomatoOrderStage
    public let orderDate: Date
    public var estimatedMinutes: Int
    public let riderName: String
    public let riderPhone: String
    public let deliveryAddress: String
    public let paymentMethod: String
    public let couponCode: String?
    
    public init(
        id: String = "ZMT-" + String(Int.random(in: 100000...999999)),
        items: [ZomatoCartItem],
        restaurantName: String,
        restaurantId: String,
        itemTotal: Double,
        deliveryFee: Double = 30,
        taxes: Double = 0,
        packagingFee: Double = 15,
        platformFee: Double = 5,
        tip: Double = 0,
        donation: Double = 0,
        couponDiscount: Double = 0,
        grandTotal: Double,
        stage: ZomatoOrderStage = .preparing,
        orderDate: Date = Date(),
        estimatedMinutes: Int = 30,
        riderName: String = "Vikram Singh",
        riderPhone: String = "+91 98765 43210",
        deliveryAddress: String = "Flat 402, Sunshine Heights, Koramangala",
        paymentMethod: String = "Google Pay (UPI)",
        couponCode: String? = nil
    ) {
        self.id = id
        self.items = items
        self.restaurantName = restaurantName
        self.restaurantId = restaurantId
        self.itemTotal = itemTotal
        self.deliveryFee = deliveryFee
        self.taxes = taxes
        self.packagingFee = packagingFee
        self.platformFee = platformFee
        self.tip = tip
        self.donation = donation
        self.couponDiscount = couponDiscount
        self.grandTotal = grandTotal
        self.stage = stage
        self.orderDate = orderDate
        self.estimatedMinutes = estimatedMinutes
        self.riderName = riderName
        self.riderPhone = riderPhone
        self.deliveryAddress = deliveryAddress
        self.paymentMethod = paymentMethod
        self.couponCode = couponCode
    }
}
