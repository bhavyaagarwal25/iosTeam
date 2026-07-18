//
//  ZomatoProfileViewModel.swift
//  trial
//

import Foundation
import Combine
import UIKit

@MainActor
public class ZomatoProfileViewModel: ObservableObject {
    public let orderService: ZomatoOrderService
    public let cartService: ZomatoCartService
    
    @Published public var pastOrders: [ZomatoOrder] = []
    @Published public var addresses: [ZomatoAddress] = MockZomatoData.addresses
    @Published public var favoriteRestaurants: [Restaurant] = []
    @Published public var darkModeEnabled: Bool = false
    @Published public var notificationsEnabled: Bool = true
    @Published public var vegModeEnabled: Bool = false
    @Published public var showPersonalisedRatings: Bool = true
    
    public let paymentMethods: [(String, String)] = [
        ("Google Pay", "g.circle.fill"),
        ("PhonePe", "p.circle.fill"),
        ("Paytm Wallet", "wallet.pass.fill"),
        ("HDFC Credit Card", "creditcard.fill"),
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.orderService = ZomatoOrderService.shared
        self.cartService = ZomatoCartService.shared
        self.pastOrders = orderService.pastOrders
        self.favoriteRestaurants = MockZomatoData.restaurants.filter { $0.isFavorite || $0.isFeatured }.prefix(5).map { $0 }
        
        orderService.$pastOrders
            .assign(to: &$pastOrders)
    }
    
    public func reorderFromPastOrder(_ order: ZomatoOrder) {
        if let restaurant = ZomatoDataService.shared.restaurant(for: order.restaurantId) {
            for item in restaurant.menuItems.prefix(3) {
                cartService.addToCart(menuItem: item, restaurant: restaurant)
            }
        }
        BlinkitTheme.triggerNotificationHaptic(.success)
    }
    
    public var userName: String { "Shreya Bhardwaj" }
    public var userPhone: String { "+91 98765 43210" }
    public var userEmail: String { "shreya@example.com" }
    public var userInitial: String { "S" }
}
