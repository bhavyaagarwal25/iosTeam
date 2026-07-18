//
//  CartService.swift
//  BlinkitFlow
//
//  Manages the active shopping cart state with local persistence and group cart synchronization.
//

import Foundation
import UIKit
import Combine

@MainActor
public class CartService: ObservableObject {
    public static let shared = CartService()
    
    @Published public private(set) var items: [CartItem] = []
    @Published public private(set) var groupCart: GroupCart? = nil
    @Published public var isGroupModeEnabled: Bool = false
    
    private let persistenceService: PersistenceServiceProtocol
    
    // Billing breakdown
    public var itemTotal: Double {
        items.reduce(0) { $0 + $1.totalCost }
    }
    
    public var totalOriginalPrice: Double {
        items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    public var totalSavings: Double {
        max(0, totalOriginalPrice - itemTotal)
    }
    
    public var handlingFee: Double {
        items.isEmpty ? 0 : 4.0
    }
    
    public var deliveryFee: Double {
        if items.isEmpty { return 0 }
        return itemTotal >= 199.0 ? 0.0 : 15.0
    }
    
    public var grandTotal: Double {
        items.isEmpty ? 0 : (itemTotal + handlingFee + deliveryFee)
    }
    
    public var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    public init(persistenceService: PersistenceServiceProtocol = PersistenceService.shared) {
        self.persistenceService = persistenceService
        
        // Always start with empty cart (hackathon demo — prevent stale items from polluting the cart)
        self.items = []
        persistenceService.saveCartItems(self.items)
        
        // Setup initial empty Group Cart
        self.groupCart = GroupCart(
            title: "House Party Groceries 🥳",
            participants: MockData.allUsers,
            items: self.items
        )
    }
    
    public func addToCart(product: Product, quantity: Int = 1, user: User = MockData.currentUser) {
        if let index = items.firstIndex(where: { $0.product.id == product.id && $0.addedBy.id == user.id }) {
            items[index].quantity += quantity
        } else {
            let newItem = CartItem(product: product, quantity: quantity, addedBy: user)
            items.append(newItem)
        }
        saveAndSync()
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public func updateQuantity(for itemId: String, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        saveAndSync()
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public func removeFromCart(itemId: String) {
        items.removeAll(where: { $0.id == itemId })
        saveAndSync()
        BlinkitTheme.triggerHaptic(.medium)
    }
    
    public func addSavedListToCart(_ savedList: SavedList) {
        for product in savedList.products {
            addToCart(product: product, quantity: 1, user: MockData.currentUser)
        }
        BlinkitTheme.triggerNotificationHaptic(.success)
    }
    
    public func clearCart() {
        items.removeAll()
        saveAndSync()
    }
    
    // DEMO: Group Cart live teammate simulation
    public func simulateTeammateAddingItem() {
        let teammate = [MockData.userRahul, MockData.userPriya].randomElement()!
        let randomProduct = MockData.sampleProducts.randomElement()!
        addToCart(product: randomProduct, quantity: 1, user: teammate)
        BlinkitTheme.triggerNotificationHaptic(.success)
    }
    
    private func saveAndSync() {
        persistenceService.saveCartItems(items)
        syncGroupCart()
    }
    
    private func syncGroupCart() {
        if var g = groupCart {
            g.items = items
            self.groupCart = g
        }
        
        if items.isEmpty {
            LiveActivityManager.shared.stopCartActivity()
        } else {
            LiveActivityManager.shared.updateCartActivity(itemCount: totalItemCount, totalAmount: grandTotal)
        }
    }
}
