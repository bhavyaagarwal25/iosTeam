//
//  ZomatoCartService.swift
//  trial
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class ZomatoCartService: ObservableObject {
    public static let shared = ZomatoCartService()
    
    @Published public private(set) var items: [ZomatoCartItem] = []
    @Published public var currentRestaurantId: String? = nil
    @Published public var currentRestaurantName: String? = nil
    @Published public var appliedCoupon: ZomatoCoupon? = nil
    @Published public var tipAmount: Double = 0
    @Published public var donationAmount: Double = 0
    @Published public var deliveryInstructions: String = ""
    
    // MARK: - Computed Bill
    
    public var itemTotal: Double {
        items.reduce(0) { $0 + $1.itemTotal }
    }
    
    public var deliveryFee: Double {
        if items.isEmpty { return 0 }
        return itemTotal >= 149 ? 0 : 30
    }
    
    public var taxes: Double {
        itemTotal * 0.05 // 5% GST
    }
    
    public var packagingFee: Double {
        items.isEmpty ? 0 : 15
    }
    
    public var platformFee: Double {
        items.isEmpty ? 0 : 5
    }
    
    public var couponDiscount: Double {
        appliedCoupon?.discountFor(orderTotal: itemTotal) ?? 0
    }
    
    public var grandTotal: Double {
        max(0, itemTotal + deliveryFee + taxes + packagingFee + platformFee + tipAmount + donationAmount - couponDiscount)
    }
    
    public var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    public var isDeliveryFree: Bool {
        deliveryFee == 0 && !items.isEmpty
    }
    
    public init() {}
    
    // MARK: - Cart Operations
    
    public func addToCart(menuItem: MenuItem, restaurant: Restaurant, quantity: Int = 1, customizations: [CustomizationGroup] = []) {
        // Check if switching restaurants
        if let currentId = currentRestaurantId, currentId != restaurant.id {
            // Clear cart for new restaurant
            items.removeAll()
        }
        
        currentRestaurantId = restaurant.id
        currentRestaurantName = restaurant.name
        
        // Check if item with same customizations already exists
        if let index = items.firstIndex(where: { $0.menuItem.id == menuItem.id && $0.customizationSummary == customizations.flatMap { $0.options }.filter { $0.isSelected }.map { $0.name }.joined(separator: ", ") }) {
            items[index].quantity += quantity
        } else {
            let newItem = ZomatoCartItem(
                menuItem: menuItem,
                restaurantId: restaurant.id,
                restaurantName: restaurant.name,
                quantity: quantity,
                selectedCustomizations: customizations
            )
            items.append(newItem)
        }
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public func updateQuantity(for itemId: String, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
            if items.isEmpty {
                currentRestaurantId = nil
                currentRestaurantName = nil
            }
        } else {
            items[index].quantity = quantity
        }
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public func removeItem(_ itemId: String) {
        items.removeAll(where: { $0.id == itemId })
        if items.isEmpty {
            currentRestaurantId = nil
            currentRestaurantName = nil
        }
        BlinkitTheme.triggerHaptic(.medium)
    }
    
    public func applyCoupon(_ coupon: ZomatoCoupon) -> Bool {
        if coupon.discountFor(orderTotal: itemTotal) > 0 {
            appliedCoupon = coupon
            BlinkitTheme.triggerNotificationHaptic(.success)
            return true
        }
        return false
    }
    
    public func removeCoupon() {
        appliedCoupon = nil
    }
    
    public func clearCart() {
        items.removeAll()
        currentRestaurantId = nil
        currentRestaurantName = nil
        appliedCoupon = nil
        tipAmount = 0
        donationAmount = 0
        deliveryInstructions = ""
    }
    
    public func setTip(_ amount: Double) {
        tipAmount = amount
    }
    
    public func toggleDonation() {
        donationAmount = donationAmount > 0 ? 0 : 1
    }
}
