//
//  CheckoutViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine

@MainActor
public class CheckoutViewModel: ObservableObject {
    public let cartService: CartService
    public let orderService: OrderService
    
    @Published public var selectedAddress: String = "Flat 402, Sunshine Heights, Koramangala, Bengaluru"
    @Published public var selectedPaymentMethod: String = "Blinkit Pay (UPI)"
    @Published public var isPlacingOrder: Bool = false
    @Published public var placedOrder: Order? = nil
    
    public let paymentOptions: [String] = [
        "Blinkit Pay (UPI)",
        "Google Pay / PhonePe",
        "Credit / Debit Card",
        "Cash on Delivery"
    ]
    
    public init() {
        self.cartService = CartService.shared
        self.orderService = OrderService.shared
    }
    
    public init(
        cartService: CartService,
        orderService: OrderService
    ) {
        self.cartService = cartService
        self.orderService = orderService
    }
    
    // DEMO: Order placement triggers Live Activity
    public func placeOrder() {
        guard !cartService.items.isEmpty else { return }
        isPlacingOrder = true
        
        let order = orderService.placeOrder(
            items: cartService.items,
            totalAmount: cartService.grandTotal,
            address: selectedAddress,
            paymentMethod: selectedPaymentMethod
        )
        
        self.placedOrder = order
        cartService.clearCart()
        isPlacingOrder = false
    }
}
