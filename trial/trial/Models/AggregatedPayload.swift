//
//  AggregatedPayload.swift
//  Eternal Lite — Batched Data Model
//
//  PURPOSE: A single Codable struct that bundles ALL data the home screen needs
//  into ONE payload. This replaces the traditional pattern of 5+ separate API calls:
//
//  TRADITIONAL (5+ round-trips):
//    1. GET /restaurants        → menu data
//    2. GET /cart               → current cart state
//    3. GET /delivery-fee       → fee calculation
//    4. GET /offers             → available offers/coupons
//    5. GET /addresses          → saved addresses
//    6. GET /last-order         → for reorder suggestions
//
//  ETERNAL LITE (1 round-trip):
//    1. GET /aggregated         → everything above in ONE response
//
//  HACKATHON ANGLE: This is the core "before/after" for the demo. The debug
//  overlay shows "API Calls: 1" vs "API Calls: 6" for the same screen.
//

import Foundation

/// A single response containing everything the app needs to render the home screen.
/// In production, the server would assemble this; here we mock it locally.
public struct AggregatedPayload: Codable {
    
    /// All restaurant data including menus
    public let restaurants: [LiteRestaurant]
    
    /// Current cart state (items + restaurant context)
    public let cart: LiteCartState
    
    /// Delivery fee calculation result
    public let deliveryFee: LiteDeliveryFee
    
    /// Available offers and coupons
    public let offers: [LiteOffer]
    
    /// User's saved addresses
    public let addresses: [LiteAddress]
    
    /// Server timestamp for cache validation
    public let serverTimestamp: Date
    
    /// ETag for conditional fetching (304 Not Modified)
    public let etag: String
}

// MARK: - Lightweight Models (Lite versions of existing models)
// These are simplified, Codable-friendly versions optimized for low bandwidth.
// No images, no heavy metadata — just what's needed to render a text-only menu.

public struct LiteRestaurant: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let cuisine: String          // "North Indian, Chinese" — single string, not array
    public let rating: Double
    public let ratingCount: Int
    public let deliveryTimeMin: Int     // Just the number, not "20-25 mins" string
    public let distanceKm: Double      // Just the number, not "1.2 km" string
    public let priceForTwo: Int
    public let isVeg: Bool
    public let isOpen: Bool
    public let offer: String?           // "60% OFF up to ₹120"
    public let menuItems: [LiteMenuItem]
    
    public init(id: String, name: String, cuisine: String, rating: Double, ratingCount: Int,
                deliveryTimeMin: Int, distanceKm: Double, priceForTwo: Int, isVeg: Bool,
                isOpen: Bool, offer: String?, menuItems: [LiteMenuItem]) {
        self.id = id; self.name = name; self.cuisine = cuisine; self.rating = rating
        self.ratingCount = ratingCount; self.deliveryTimeMin = deliveryTimeMin
        self.distanceKm = distanceKm; self.priceForTwo = priceForTwo; self.isVeg = isVeg
        self.isOpen = isOpen; self.offer = offer; self.menuItems = menuItems
    }
}

public struct LiteMenuItem: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let price: Double
    public let isVeg: Bool
    public let isBestseller: Bool
    public let section: String          // "Most Ordered", "Recommended"
    
    public init(id: String, name: String, price: Double, isVeg: Bool, isBestseller: Bool, section: String) {
        self.id = id; self.name = name; self.price = price; self.isVeg = isVeg
        self.isBestseller = isBestseller; self.section = section
    }
}

public struct LiteCartState: Codable {
    public let items: [LiteCartItem]
    public let restaurantId: String?
    public let restaurantName: String?
    
    public init(items: [LiteCartItem] = [], restaurantId: String? = nil, restaurantName: String? = nil) {
        self.items = items; self.restaurantId = restaurantId; self.restaurantName = restaurantName
    }
}

public struct LiteCartItem: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let price: Double
    public let quantity: Int
    public let isVeg: Bool
    
    public init(id: String, name: String, price: Double, quantity: Int, isVeg: Bool) {
        self.id = id; self.name = name; self.price = price; self.quantity = quantity; self.isVeg = isVeg
    }
}

public struct LiteDeliveryFee: Codable {
    public let amount: Double
    public let isFree: Bool
    public let freeAbove: Double        // "Free delivery above ₹149"
    
    public init(amount: Double = 30, isFree: Bool = false, freeAbove: Double = 149) {
        self.amount = amount; self.isFree = isFree; self.freeAbove = freeAbove
    }
}

public struct LiteOffer: Codable, Identifiable {
    public let id: String
    public let code: String
    public let title: String            // "60% OFF up to ₹120"
    public let minOrder: Double
    
    public init(id: String, code: String, title: String, minOrder: Double) {
        self.id = id; self.code = code; self.title = title; self.minOrder = minOrder
    }
}

public struct LiteAddress: Codable, Identifiable, Hashable {
    public let id: String
    public let label: String            // "Home", "Office"
    public let address: String          // Full address string
    
    public init(id: String, label: String, address: String) {
        self.id = id; self.label = label; self.address = address
    }
}
