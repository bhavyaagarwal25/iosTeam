//
//  Product.swift
//  BlinkitFlow
//

import Foundation

public enum ProductCategory: String, CaseIterable, Codable, Identifiable {
    case all = "All"
    case fruitsVeg = "Fruits & Veg"
    case dairy = "Dairy & Bread"
    case snacks = "Snacks & Munchies"
    case beverages = "Cold Drinks & Juices"
    case household = "Household Essentials"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .fruitsVeg: return "carrot.fill"
        case .dairy: return "drop.fill"
        case .snacks: return "popcorn.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .household: return "house.fill"
        }
    }
}

public struct Product: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let category: ProductCategory
    public let price: Double
    public let discountPrice: Double?
    public let unit: String
    public let systemImage: String
    public let rating: Double
    public let deliveryTime: String
    public let description: String
    public let isPopular: Bool
    public let tag: String?
    
    public var effectivePrice: Double {
        discountPrice ?? price
    }
    
    public var savingsPercentage: Int? {
        guard let discount = discountPrice, discount < price else { return nil }
        let diff = price - discount
        return Int((diff / price) * 100)
    }
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        category: ProductCategory,
        price: Double,
        discountPrice: Double? = nil,
        unit: String,
        systemImage: String,
        rating: Double = 4.5,
        deliveryTime: String = "8-10 mins",
        description: String = "Fresh, premium quality item delivered directly to your doorstep in minutes.",
        isPopular: Bool = false,
        tag: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.price = price
        self.discountPrice = discountPrice
        self.unit = unit
        self.systemImage = systemImage
        self.rating = rating
        self.deliveryTime = deliveryTime
        self.description = description
        self.isPopular = isPopular
        self.tag = tag
    }
}
