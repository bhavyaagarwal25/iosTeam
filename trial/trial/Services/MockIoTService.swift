//
//  MockIoTService.swift
//  Blinkit Home Inventory AI
//
//  Simulates a Smart Fridge IoT API service with dynamic state updates post-order.
//

import Foundation

/// Abstract protocol for fetching IoT Smart Fridge inventory.
public protocol IoTServiceProtocol: Sendable {
    func fetchSmartFridgeSnapshot() async throws -> InventorySnapshot
}

public final class MockIoTService: IoTServiceProtocol, @unchecked Sendable {
    public static let shared = MockIoTService()
    
    private let lock = NSLock()
    
    /// Dynamic dictionary representing current IoT telemetry from the Smart Fridge.
    private var fridgeTelemetry: [String: Int] = [
        "milk": 0,
        "butter": 0,
        "cheese": 0,
        "icecream": 0,
        "dahi": 0,
        "eggs": 2,
        "juice": 1,
        "bread": 1,
        "sauce": 1,
        "fruits": 2,
        "vegetables": 3,
        "jam": 1
    ]
    
    public init() {
        // Always reset to defaults on launch — clears stale UserDefaults telemetry from old sessions
        UserDefaults.standard.removeObject(forKey: "blinkit_mock_iot_telemetry_v2")
    }
    
    public func fetchSmartFridgeSnapshot() async throws -> InventorySnapshot {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        
        lock.lock()
        let currentDict = self.fridgeTelemetry
        lock.unlock()
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let rawJSON = (try? String(data: jsonEncoder.encode(currentDict), encoding: .utf8)) ?? "{}"
        
        return InventorySnapshot(
            timestamp: Date(),
            source: .smartFridge,
            itemQuantities: currentDict,
            rawPayload: rawJSON
        )
    }
    
    public func updateFridgeTelemetry(with inventoryItems: [InventoryItem]) {
        lock.lock()
        for item in inventoryItems {
            let key = item.name.lowercased()
            fridgeTelemetry[key] = item.currentQuantity
        }
        let dictToSave = self.fridgeTelemetry
        lock.unlock()
        
        if let data = try? JSONEncoder().encode(dictToSave) {
            UserDefaults.standard.set(data, forKey: "blinkit_mock_iot_telemetry_v2")
        }
    }
    
    public func resetTelemetryToDefaults() {
        lock.lock()
        self.fridgeTelemetry = [
            "milk": 0,
            "butter": 0,
            "cheese": 0,
            "icecream": 0,
            "dahi": 0,
            "eggs": 2,
            "juice": 1,
            "bread": 1,
            "sauce": 1,
            "fruits": 2,
            "vegetables": 3,
            "jam": 1
        ]
        let dictToSave = self.fridgeTelemetry
        lock.unlock()
        
        if let data = try? JSONEncoder().encode(dictToSave) {
            UserDefaults.standard.set(data, forKey: "blinkit_mock_iot_telemetry_v2")
        }
    }
}
