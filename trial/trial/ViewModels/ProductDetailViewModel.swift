//
//  ProductDetailViewModel.swift
//  BlinkitFlow
//

import Foundation
import UIKit
import Combine

@MainActor
public class ProductDetailViewModel: ObservableObject {
    @Published public var product: Product
    @Published public var selectedQuantity: Int = 1
    
    public let cartService: CartService
    
    public var cartQuantity: Int {
        cartService.items
            .filter { $0.product.id == product.id }
            .reduce(0) { $0 + $1.quantity }
    }
    
    public init(product: Product) {
        self.product = product
        self.cartService = CartService.shared
    }
    
    public init(
        product: Product,
        cartService: CartService
    ) {
        self.product = product
        self.cartService = cartService
    }
    
    public func addToCart() {
        cartService.addToCart(product: product, quantity: selectedQuantity, user: MockData.currentUser)
        BlinkitTheme.triggerHaptic(.medium)
    }
    
    public func incrementQuantity() {
        selectedQuantity += 1
        if cartQuantity > 0 {
            addToCart()
        }
    }
    
    public func decrementQuantity() {
        if selectedQuantity > 1 {
            selectedQuantity -= 1
        }
    }
}
