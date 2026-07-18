//
//  ZomatoCoupon.swift
//  trial
//

import Foundation

public enum CouponDiscountType: String, Codable {
    case flat = "flat"
    case percentage = "percentage"
}

public struct ZomatoCoupon: Identifiable, Codable, Hashable {
    public let id: String
    public let code: String
    public let title: String
    public let description: String
    public let discountType: CouponDiscountType
    public let discountValue: Double
    public let minOrderAmount: Double
    public let maxDiscount: Double?
    
    public func discountFor(orderTotal: Double) -> Double {
        guard orderTotal >= minOrderAmount else { return 0 }
        switch discountType {
        case .flat:
            return discountValue
        case .percentage:
            let discount = orderTotal * (discountValue / 100)
            if let max = maxDiscount {
                return min(discount, max)
            }
            return discount
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        code: String,
        title: String,
        description: String,
        discountType: CouponDiscountType,
        discountValue: Double,
        minOrderAmount: Double = 0,
        maxDiscount: Double? = nil
    ) {
        self.id = id
        self.code = code
        self.title = title
        self.description = description
        self.discountType = discountType
        self.discountValue = discountValue
        self.minOrderAmount = minOrderAmount
        self.maxDiscount = maxDiscount
    }
}
