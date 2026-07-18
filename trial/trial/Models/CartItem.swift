//
//  CartItem.swift
//  BlinkitFlow
//

import Foundation

public struct CartItem: Identifiable, Codable, Hashable {
    public let id: String
    public let product: Product
    public var quantity: Int
    public let addedBy: User
    public let addedAt: Date
    
    public var totalCost: Double {
        product.effectivePrice * Double(quantity)
    }
    
    public init(
        id: String = UUID().uuidString,
        product: Product,
        quantity: Int = 1,
        addedBy: User,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.product = product
        self.quantity = quantity
        self.addedBy = addedBy
        self.addedAt = addedAt
    }
}
