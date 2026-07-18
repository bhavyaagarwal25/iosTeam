//
//  ZomatoCartItem.swift
//  trial
//

import Foundation

public struct ZomatoCartItem: Identifiable, Codable, Hashable {
    public let id: String
    public let menuItem: MenuItem
    public let restaurantId: String
    public let restaurantName: String
    public var quantity: Int
    public let selectedCustomizations: [CustomizationGroup]
    public var specialInstructions: String
    
    public var itemTotal: Double {
        let customizationPrice = selectedCustomizations.flatMap { $0.options }.filter { $0.isSelected }.reduce(0) { $0 + $1.price }
        return (menuItem.price + customizationPrice) * Double(quantity)
    }
    
    public var customizationSummary: String {
        let selected = selectedCustomizations.flatMap { $0.options }.filter { $0.isSelected }.map { $0.name }
        return selected.isEmpty ? "" : selected.joined(separator: ", ")
    }
    
    public init(
        id: String = UUID().uuidString,
        menuItem: MenuItem,
        restaurantId: String,
        restaurantName: String,
        quantity: Int = 1,
        selectedCustomizations: [CustomizationGroup] = [],
        specialInstructions: String = ""
    ) {
        self.id = id
        self.menuItem = menuItem
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.quantity = quantity
        self.selectedCustomizations = selectedCustomizations
        self.specialInstructions = specialInstructions
    }
}
