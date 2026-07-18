//
//  ZomatoCartViewModel.swift
//  trial
//

import Foundation
import Combine
import UIKit

@MainActor
public class ZomatoCartViewModel: ObservableObject {
    public let cartService: ZomatoCartService
    
    @Published public var showCouponEntry: Bool = false
    @Published public var couponCode: String = ""
    @Published public var couponError: String? = nil
    @Published public var showCheckout: Bool = false
    
    public let tipOptions: [Double] = [20, 30, 50]
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.cartService = ZomatoCartService.shared
        cartService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    public func updateQuantity(item: ZomatoCartItem, delta: Int) {
        cartService.updateQuantity(for: item.id, quantity: item.quantity + delta)
    }
    
    public func removeItem(_ item: ZomatoCartItem) {
        cartService.removeItem(item.id)
    }
    
    public func applyCoupon() {
        let code = couponCode.uppercased().trimmingCharacters(in: .whitespaces)
        if let coupon = MockZomatoData.coupons.first(where: { $0.code == code }) {
            if cartService.applyCoupon(coupon) {
                couponError = nil
                showCouponEntry = false
            } else {
                couponError = "Minimum order of ₹\(Int(coupon.minOrderAmount)) required"
            }
        } else {
            couponError = "Invalid coupon code"
        }
    }
    
    public func selectTip(_ amount: Double) {
        if cartService.tipAmount == amount {
            cartService.setTip(0)
        } else {
            cartService.setTip(amount)
        }
    }
    
    public var availableCoupons: [ZomatoCoupon] {
        MockZomatoData.coupons.filter { $0.discountFor(orderTotal: cartService.itemTotal) > 0 }
    }
}
