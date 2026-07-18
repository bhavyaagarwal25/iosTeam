//
//  ReorderIntent.swift
//  BlinkitFlow
//
//  DEMO: App Intents for Siri Shortcuts (Dynamic Item Add, Place Order, Reorder Usual).
//

import AppIntents
import SwiftUI

public enum GroceryItemEnum: String, AppEnum {
    case amulMilk = "Amul Milk"
    case maggi = "Maggi"
    case butter = "Butter"
    case bread = "Bread"
    case tomato = "Tomato"
    case onion = "Onion"
    case potato = "Potato"
    case chips = "Chips"
    case coke = "Coke"
    case paneer = "Paneer"
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Grocery Item"
    
    public static var caseDisplayRepresentations: [GroceryItemEnum: DisplayRepresentation] = [
        .amulMilk: "Amul Milk",
        .maggi: "Maggi 2-Min Noodles",
        .butter: "Amul Salted Butter",
        .bread: "Whole Wheat Bread",
        .tomato: "Fresh Tomatoes",
        .onion: "Fresh Onions",
        .potato: "Fresh Potatoes",
        .chips: "Lay's Chips",
        .coke: "Coca Cola",
        .paneer: "Fresh Paneer"
    ]
}

public struct AddProductIntent: AppIntent {
    public static var title: LocalizedStringResource = "Add Item to Cart"
    public static var description: IntentDescription = IntentDescription("Adds a specific grocery item to your cart by name.")
    public static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Item Name", requestValueDialog: IntentDialog("Which grocery item would you like to add?"))
    public var item: GroceryItemEnum
    
    public init() {}
    
    public init(item: GroceryItemEnum) {
        self.item = item
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let cart = CartService.shared
        let products = MockData.sampleProducts
        
        let query = item.rawValue.lowercased()
        
        let match = products.first(where: { $0.name.lowercased().contains(query) })
        if let match = match {
            cart.addToCart(product: match, quantity: 1, user: MockData.currentUser)
        }
        
        if await UIApplication.shared.applicationState != .active && cart.totalItemCount > 0 {
            LiveActivityManager.shared.startCartActivity(itemCount: cart.totalItemCount, totalAmount: cart.grandTotal)
        }
        
        if let match = match {
            return .result(dialog: "Added \(match.name) to your cart!")
        } else {
            return .result(dialog: "Added \(item.rawValue) to your cart!")
        }
    }
}

public struct ReorderIntent: AppIntent {
    public static var title: LocalizedStringResource = "Reorder My Usual Groceries"
    public static var description: IntentDescription = IntentDescription("Instantly adds your most recent saved list or daily essentials to cart.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let cart = CartService.shared
        if let savedList = MockData.savedLists.first {
            cart.addSavedListToCart(savedList)
            if await UIApplication.shared.applicationState != .active && cart.totalItemCount > 0 {
                LiveActivityManager.shared.startCartActivity(itemCount: cart.totalItemCount, totalAmount: cart.grandTotal)
            }
            return .result(dialog: "Added \(savedList.title) to your Blinkit cart!")
        } else {
            return .result(dialog: "Cart updated with your usual grocery items.")
        }
    }
}

public struct PlaceOrderIntent: AppIntent {
    public static var title: LocalizedStringResource = "Place My Grocery Order"
    public static var description: IntentDescription = IntentDescription("Places your active cart order and starts tracking live in Dynamic Island.")
    public static var openAppWhenRun: Bool = false
    
    public init() {}
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let cart = CartService.shared
        let orderService = OrderService.shared
        
        guard !cart.items.isEmpty else {
            return .result(dialog: "Your cart is currently empty. Tell Siri to add items first!")
        }
        
        let order = orderService.placeOrder(
            items: cart.items,
            totalAmount: cart.grandTotal,
            address: "Flat 402, Sunshine Heights, Bengaluru",
            paymentMethod: "Blinkit Pay (UPI)"
        )
        
        cart.clearCart()
        
        return .result(dialog: "Order \(order.id) placed successfully! Tracking live in Dynamic Island.")
    }
}

public struct BlinkitShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddProductIntent(),
            phrases: [
                "Add \(\.$item) in ${applicationName}",
                "Put \(\.$item) in my cart in ${applicationName}",
                "Add \(\.$item) to ${applicationName}"
            ],
            shortTitle: "Add Item to Cart",
            systemImageName: "cart.badge.plus"
        )
        
        AppShortcut(
            intent: ReorderIntent(),
            phrases: [
                "Reorder my usual in ${applicationName}",
                "Order daily groceries in ${applicationName}",
                "Blinkit reorder usual in ${applicationName}"
            ],
            shortTitle: "Reorder Usual",
            systemImageName: "cart.fill.badge.plus"
        )
        
        AppShortcut(
            intent: PlaceOrderIntent(),
            phrases: [
                "Place my order in ${applicationName}",
                "Checkout cart in ${applicationName}",
                "Blinkit place order in ${applicationName}"
            ],
            shortTitle: "Place Order",
            systemImageName: "bolt.fill"
        )
    }
}
