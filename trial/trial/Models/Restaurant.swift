//
//  Restaurant.swift
//  trial
//
//  Zomato Food Delivery Models
//

import Foundation

// MARK: - Cuisine Categories

public enum ZomatoCategory: String, CaseIterable, Codable, Identifiable {
    case all = "All"
    case pizza = "Pizza"
    case burger = "Burger"
    case chinese = "Chinese"
    case biryani = "Biryani"
    case southIndian = "South Indian"
    case italian = "Italian"
    case rolls = "Rolls"
    case desserts = "Desserts"
    case coffee = "Coffee"
    case healthy = "Healthy"
    case paratha = "Paratha"
    case northIndian = "North Indian"
    case thali = "Thali"
    case streetFood = "Street Food"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .pizza: return "🍕"
        case .burger: return "🍔"
        case .chinese: return "🥡"
        case .biryani: return "🍛"
        case .southIndian: return "🥘"
        case .italian: return "🍝"
        case .rolls: return "🌯"
        case .desserts: return "🍰"
        case .coffee: return "☕"
        case .healthy: return "🥗"
        case .paratha: return "🥞"
        case .northIndian: return "🍲"
        case .thali: return "🍱"
        case .streetFood: return "🌮"
        }
    }
}

// MARK: - Customization

public struct CustomizationOption: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let price: Double
    public var isSelected: Bool
    
    public init(id: String = UUID().uuidString, name: String, price: Double = 0, isSelected: Bool = false) {
        self.id = id
        self.name = name
        self.price = price
        self.isSelected = isSelected
    }
}

public struct CustomizationGroup: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public var options: [CustomizationOption]
    public let isRequired: Bool
    public let maxSelections: Int // 1 = radio, >1 = checkbox
    
    public init(id: String = UUID().uuidString, name: String, options: [CustomizationOption], isRequired: Bool = false, maxSelections: Int = 1) {
        self.id = id
        self.name = name
        self.options = options
        self.isRequired = isRequired
        self.maxSelections = maxSelections
    }
}

// MARK: - Menu Item

public struct MenuItem: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let price: Double
    public let isVeg: Bool
    public let imageName: String
    public let rating: Double?
    public let numberOfRatings: Int?
    public let description: String?
    public let isBestseller: Bool
    public let isCustomisable: Bool
    public let isHighlyOrdered: Bool
    public let isRecommended: Bool
    public let menuSection: String // "Most Ordered", "Recommended", "Combos", "Drinks", "Desserts"
    public let customizationGroups: [CustomizationGroup]
    
    // Legacy compat
    public var systemImage: String { imageName }
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        price: Double,
        isVeg: Bool,
        imageName: String = "pizza",
        rating: Double? = nil,
        numberOfRatings: Int? = nil,
        description: String? = nil,
        isBestseller: Bool = false,
        isCustomisable: Bool = false,
        isHighlyOrdered: Bool = false,
        isRecommended: Bool = false,
        menuSection: String = "Recommended",
        customizationGroups: [CustomizationGroup] = []
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.isVeg = isVeg
        self.imageName = imageName
        self.rating = rating
        self.numberOfRatings = numberOfRatings
        self.description = description
        self.isBestseller = isBestseller
        self.isCustomisable = isCustomisable
        self.isHighlyOrdered = isHighlyOrdered
        self.isRecommended = isRecommended
        self.menuSection = menuSection
        self.customizationGroups = customizationGroups
    }
}

// MARK: - Restaurant

public struct Restaurant: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let categories: [ZomatoCategory]
    public let rating: Double
    public let numberOfRatings: Int
    public let deliveryTime: String
    public let distance: String
    public let offer: String?
    public let imageName: String
    public let isPureVeg: Bool
    public let menuItems: [MenuItem]
    public let cuisineText: String
    public let priceForTwo: Int
    public let isSponsored: Bool
    public let isFeatured: Bool
    public var isFavorite: Bool
    public let badges: [String] // e.g. "Frequently Reordered", "Low Plastic"
    public let isOpen: Bool
    
    // Legacy compat
    public var systemImage: String { imageName }
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        categories: [ZomatoCategory],
        rating: Double,
        numberOfRatings: Int = 500,
        deliveryTime: String,
        distance: String,
        offer: String? = nil,
        imageName: String = "pizza",
        isPureVeg: Bool = false,
        menuItems: [MenuItem] = [],
        cuisineText: String = "Multi Cuisine",
        priceForTwo: Int = 400,
        isSponsored: Bool = false,
        isFeatured: Bool = false,
        isFavorite: Bool = false,
        badges: [String] = [],
        isOpen: Bool = true
    ) {
        self.id = id
        self.name = name
        self.categories = categories
        self.rating = rating
        self.numberOfRatings = numberOfRatings
        self.deliveryTime = deliveryTime
        self.distance = distance
        self.offer = offer
        self.imageName = imageName
        self.isPureVeg = isPureVeg
        self.menuItems = menuItems
        self.cuisineText = cuisineText
        self.priceForTwo = priceForTwo
        self.isSponsored = isSponsored
        self.isFeatured = isFeatured
        self.isFavorite = isFavorite
        self.badges = badges
        self.isOpen = isOpen
    }
}
