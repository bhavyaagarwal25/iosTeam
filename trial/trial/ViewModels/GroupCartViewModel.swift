//
//  GroupCartViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine

@MainActor
public class GroupCartViewModel: ObservableObject {
    public let cartService: CartService
    @Published public var inviteCode: String = "BLINK-PARTY-99"
    @Published public var inviteURL: String = "https://blinkit.app/cart/invite?code=BLINK-PARTY-99"
    
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
    
    // DEMO: Simulate teammate adding item live button handler
    public func simulateTeammateItemAdd() {
        cartService.simulateTeammateAddingItem()
    }
}
