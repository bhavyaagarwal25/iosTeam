//
//  CartViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine

@MainActor
public class CartViewModel: ObservableObject {
    public let cartService: CartService
    public let savedLists: [SavedList] = MockData.savedLists
    
    @Published public var showGroupCart: Bool = false
    @Published public var showCheckout: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.cartService = CartService.shared
        setupSubscriptions()
    }
    
    public init(cartService: CartService) {
        self.cartService = cartService
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        cartService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public func updateQuantity(item: CartItem, delta: Int) {
        let newQty = item.quantity + delta
        cartService.updateQuantity(for: item.id, quantity: newQty)
    }
    
    public func deleteItem(_ item: CartItem) {
        cartService.removeFromCart(itemId: item.id)
    }
    
    public func addSavedList(_ list: SavedList) {
        cartService.addSavedListToCart(list)
    }
}
