//
//  OrderTrackingViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine
import CoreLocation

@MainActor
public class OrderTrackingViewModel: ObservableObject {
    public let orderService: OrderService
    
    @Published public var activeOrder: Order?
    @Published public var nearbyPlayers: [NearbyPlayer] = [
        NearbyPlayer(name: "Anirudh", coordinate: CLLocationCoordinate2D(latitude: 12.9358, longitude: 77.6258)),
        NearbyPlayer(name: "Priya", coordinate: CLLocationCoordinate2D(latitude: 12.9345, longitude: 77.6225))
    ]
    
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

public struct NearbyPlayer: Identifiable, Equatable {
    public let id = UUID()
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    
    public static func == (lhs: NearbyPlayer, rhs: NearbyPlayer) -> Bool {
        lhs.id == rhs.id
    }
}
