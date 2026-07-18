//
//  ZomatoRestaurantViewModel.swift
//  trial
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class ZomatoRestaurantViewModel: ObservableObject {
    @Published public var restaurant: Restaurant
    @Published public var searchText: String = ""
    @Published public var vegOnly: Bool = false
    @Published public var showCustomizationSheet: Bool = false
    @Published public var selectedMenuItem: MenuItem? = nil
    @Published public var customizationGroups: [CustomizationGroup] = []
    
    public let cartService: ZomatoCartService
    
    public init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.cartService = ZomatoCartService.shared
    }
    
    // MARK: - Menu Sections
    
    public var menuSections: [(String, [MenuItem])] {
        let sections = Dictionary(grouping: filteredItems) { $0.menuSection }
        let order = ["Most Ordered", "Recommended", "Combos", "Drinks", "Desserts"]
        return order.compactMap { section in
            if let items = sections[section], !items.isEmpty {
                return (section, items)
            }
            return nil
        }
    }
    
    public var filteredItems: [MenuItem] {
        var items = restaurant.menuItems
        
        if vegOnly {
            items = items.filter { $0.isVeg }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            items = items.filter {
                $0.name.lowercased().contains(query) ||
                ($0.description?.lowercased().contains(query) ?? false)
            }
        }
        
        return items
    }
    
    // MARK: - Cart Operations
    
    public func prepareCustomization(for item: MenuItem) {
        selectedMenuItem = item
        if item.isCustomisable && !item.customizationGroups.isEmpty {
            customizationGroups = item.customizationGroups
            showCustomizationSheet = true
        } else {
            addToCartDirectly(item)
        }
    }
    
    public func addToCartDirectly(_ item: MenuItem) {
        cartService.addToCart(menuItem: item, restaurant: restaurant)
    }
    
    public func addToCartWithCustomizations() {
        guard let item = selectedMenuItem else { return }
        cartService.addToCart(menuItem: item, restaurant: restaurant, customizations: customizationGroups)
        showCustomizationSheet = false
        selectedMenuItem = nil
    }
    
    public func quantityInCart(for menuItem: MenuItem) -> Int {
        cartService.items.filter { $0.menuItem.id == menuItem.id && $0.restaurantId == restaurant.id }.reduce(0) { $0 + $1.quantity }
    }
    
    public var isCurrentRestaurant: Bool {
        cartService.currentRestaurantId == nil || cartService.currentRestaurantId == restaurant.id
    }
    
    // MARK: - Customization Helpers
    
    public func toggleOption(groupId: String, optionId: String) {
        guard let gIdx = customizationGroups.firstIndex(where: { $0.id == groupId }) else { return }
        guard let oIdx = customizationGroups[gIdx].options.firstIndex(where: { $0.id == optionId }) else { return }
        
        if customizationGroups[gIdx].maxSelections == 1 {
            // Radio: deselect all others first
            for i in customizationGroups[gIdx].options.indices {
                customizationGroups[gIdx].options[i].isSelected = false
            }
            customizationGroups[gIdx].options[oIdx].isSelected = true
        } else {
            // Checkbox
            customizationGroups[gIdx].options[oIdx].isSelected.toggle()
        }
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public var customizationTotal: Double {
        guard let item = selectedMenuItem else { return 0 }
        let extraPrice = customizationGroups.flatMap { $0.options }.filter { $0.isSelected }.reduce(0) { $0 + $1.price }
        return item.price + extraPrice
    }
}
