//
//  ProfileViewModel.swift
//  BlinkitFlow
//

import Foundation
import UIKit
import Combine
import UserNotifications

@MainActor
public class ProfileViewModel: ObservableObject {
    public let orderService: OrderService
    public let cartService: CartService
    
    @Published public var pastOrders: [Order] = []
    @Published public var runningLowProducts: [Product] = []
    @Published public var notificationScheduled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.orderService = OrderService.shared
        self.cartService = CartService.shared
        self.pastOrders = OrderService.shared.pastOrders
        
        self.runningLowProducts = [
            MockData.sampleProducts[0],
            MockData.sampleProducts[2],
            MockData.sampleProducts[5]
        ]
        
        orderService.$pastOrders
            .assign(to: &$pastOrders)
            
        cartService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public init(
        orderService: OrderService,
        cartService: CartService
    ) {
        self.orderService = orderService
        self.cartService = cartService
        self.pastOrders = orderService.pastOrders
        
        self.runningLowProducts = [
            MockData.sampleProducts[0],
            MockData.sampleProducts[2],
            MockData.sampleProducts[5]
        ]
        
        orderService.$pastOrders
            .assign(to: &$pastOrders)
            
        cartService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public func reorderOrder(_ order: Order) {
        orderService.reorderPastOrder(order, cartService: cartService)
    }
    
    public func reorderSingleProduct(_ product: Product) {
        cartService.addToCart(product: product, quantity: 1, user: MockData.currentUser)
        BlinkitTheme.triggerNotificationHaptic(.success)
    }
    
    // DEMO: Schedule local notification for "Running low" nudge
    public func scheduleRunningLowNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Running Low on Milk & Bread? 🥛"
                content.body = "Your usual morning staples were ordered 3 days ago. Tap to reorder in 1-click!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
                let request = UNNotificationRequest(identifier: "running_low_nudge", content: content, trigger: trigger)
                
                center.add(request) { _ in
                    Task { @MainActor in
                        self.notificationScheduled = true
                        BlinkitTheme.triggerNotificationHaptic(.success)
                    }
                }
            }
        }
    }
}
