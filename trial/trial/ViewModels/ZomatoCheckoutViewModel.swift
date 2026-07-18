//
//  ZomatoCheckoutViewModel.swift
//  trial
//

import Foundation
import Combine
import SwiftUI

public enum ZomatoPaymentCategory: String, CaseIterable, Identifiable {
    case upi = "UPI (Instant Payment)"
    case cards = "Credit / Debit Cards"
    case payLater = "Pay Later & Wallets"
    case cod = "Pay on Delivery"
    
    public var id: String { rawValue }
}

public struct ZomatoPaymentOption: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let category: ZomatoPaymentCategory
    public let iconName: String
    public let badgeText: String?
    public let offerText: String?
    
    public init(id: String, name: String, category: ZomatoPaymentCategory, iconName: String, badgeText: String? = nil, offerText: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.iconName = iconName
        self.badgeText = badgeText
        self.offerText = offerText
    }
}

@MainActor
public class ZomatoCheckoutViewModel: ObservableObject {
    public let cartService: ZomatoCartService
    public let orderService: ZomatoOrderService
    
    @Published public var selectedAddress: ZomatoAddress
    @Published public var selectedPaymentOption: ZomatoPaymentOption
    @Published public var isScheduled: Bool = false
    @Published public var scheduledDate: Date = Date().addingTimeInterval(3600)
    @Published public var isPlacingOrder: Bool = false
    @Published public var placedOrder: ZomatoOrder? = nil
    @Published public var showPaymentProcessing: Bool = false
    
    public let addresses: [ZomatoAddress] = MockZomatoData.addresses
    
    public let paymentOptions: [ZomatoPaymentOption] = [
        ZomatoPaymentOption(id: "gpay", name: "Google Pay (UPI)", category: .upi, iconName: "g.circle.fill", badgeText: "RECOMMENDED", offerText: "Up to ₹50 cashback"),
        ZomatoPaymentOption(id: "phonepe", name: "PhonePe (UPI)", category: .upi, iconName: "p.circle.fill", badgeText: "POPULAR", offerText: "Flat ₹25 cashback"),
        ZomatoPaymentOption(id: "paytm_upi", name: "Paytm UPI", category: .upi, iconName: "wallet.pass.fill", offerText: "Assured reward points"),
        ZomatoPaymentOption(id: "cred_upi", name: "CRED Pay (UPI)", category: .upi, iconName: "c.circle.fill", offerText: "Earn CRED coins"),
        
        ZomatoPaymentOption(id: "card", name: "Credit / Debit Card", category: .cards, iconName: "creditcard.fill", offerText: "HDFC, ICICI, SBI 10% Off"),
        
        ZomatoPaymentOption(id: "paytm_wallet", name: "Paytm Wallet", category: .payLater, iconName: "wallet.pass.fill"),
        ZomatoPaymentOption(id: "simpl", name: "Simpl / LazyPay", category: .payLater, iconName: "bolt.horizontal.circle.fill", offerText: "Pay next month"),
        
        ZomatoPaymentOption(id: "cod", name: "Cash on Delivery", category: .cod, iconName: "banknote.fill")
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.cartService = ZomatoCartService.shared
        self.orderService = ZomatoOrderService.shared
        self.selectedAddress = MockZomatoData.addresses.first(where: { $0.isDefault }) ?? MockZomatoData.addresses[0]
        self.selectedPaymentOption = paymentOptions[0]
        
        cartService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    public func placeOrder() {
        guard !cartService.items.isEmpty else { return }
        isPlacingOrder = true
        showPaymentProcessing = true
        
        // Simulate real payment delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            guard let self = self else { return }
            let order = self.orderService.placeOrder(
                cartService: self.cartService,
                address: self.selectedAddress.fullAddress,
                paymentMethod: self.selectedPaymentOption.name
            )
            self.placedOrder = order
            self.isPlacingOrder = false
            self.showPaymentProcessing = false
        }
    }
    
    public var deliveryTimeText: String {
        if isScheduled {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return "Scheduled: \(formatter.string(from: scheduledDate))"
        }
        return "25-35 mins"
    }
}
