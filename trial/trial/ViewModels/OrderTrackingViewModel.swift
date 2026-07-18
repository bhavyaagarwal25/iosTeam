//
//  OrderTrackingViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine

@MainActor
public class OrderTrackingViewModel: ObservableObject {
    public let orderService: OrderService
    
    @Published public var activeOrder: Order?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.orderService = OrderService.shared
        self.activeOrder = OrderService.shared.activeOrder
        
        OrderService.shared.$activeOrder
            .assign(to: &$activeOrder)
    }
    
    public init(orderService: OrderService) {
        self.orderService = orderService
        self.activeOrder = orderService.activeOrder
        
        orderService.$activeOrder
            .assign(to: &$activeOrder)
    }
    
    public func manualAdvanceStage() {
        orderService.advanceOrderStage()
    }
}
