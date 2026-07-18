//
//  ZomatoOrderTrackingViewModel.swift
//  trial
//

import Foundation
import Combine
import UIKit

@MainActor
public class ZomatoOrderTrackingViewModel: ObservableObject {
    public let orderService: ZomatoOrderService
    
    @Published public var etaCountdown: Int = 30
    
    private var cancellables = Set<AnyCancellable>()
    private var countdownTimer: Timer?
    
    public init() {
        self.orderService = ZomatoOrderService.shared
        
        orderService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.updateETA()
            }
            .store(in: &cancellables)
        
        startCountdown()
    }
    
    public var activeOrder: ZomatoOrder? {
        orderService.activeOrder
    }
    
    public var stages: [ZomatoOrderStage] {
        ZomatoOrderStage.allCases
    }
    
    public var currentStageIndex: Int {
        guard let stage = activeOrder?.stage else { return 0 }
        return stages.firstIndex(of: stage) ?? 0
    }
    
    public var isDelivered: Bool {
        activeOrder?.stage == .delivered
    }
    
    private func updateETA() {
        etaCountdown = activeOrder?.estimatedMinutes ?? 0
    }
    
    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.etaCountdown > 0 {
                    self.etaCountdown -= 1
                }
            }
        }
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
}
