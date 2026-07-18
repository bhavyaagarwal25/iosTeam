//
//  MockVisionService.swift
//  Blinkit Home Inventory AI
//
//  Simulates Apple Vision Framework + CoreML object detection on captured pantry photos.
//  Protocol-oriented design allows plugging in VNRecognizeObjectsRequest or VNCoreMLRequest seamlessly.
//

import Foundation
import UIKit

/// Abstract interface for image object recognition pipeline.
public protocol VisionServiceProtocol: Sendable {
    func analyzePantryImage(_ image: UIImage?) async throws -> InventorySnapshot
}

public final class MockVisionService: VisionServiceProtocol {
    public static let shared = MockVisionService()
    
    /// Tracks scan count to simulate changing pantry conditions across subsequent scans.
    private var scanCount: Int = 0
    
    public init() {}
    
    public func analyzePantryImage(_ image: UIImage?) async throws -> InventorySnapshot {
        // Simulate Vision + CoreML processing time
        try await Task.sleep(nanoseconds: 1_200_000_000) // 1.2s
        
        scanCount += 1
        
        let detectedItems: [String: Int]
        
        if scanCount == 1 {
            // First Pantry Scan result:
            // Rice=1 (Available), Oil=0 (Missing), Salt=1 (Available), Sugar=1 (Available), Coffee=0 (Missing), Tea=2 (Available)
            detectedItems = [
                "rice": 1,
                "oil": 0,
                "salt": 1,
                "sugar": 1,
                "coffee": 0,
                "tea": 2
            ]
        } else {
            // Subsequent Pantry Scan result:
            // Oil and Coffee were previously restocked, but now Tea becomes 0 (Missing) and Juice is 0 (Missing)
            detectedItems = [
                "rice": 1,
                "oil": 2,
                "salt": 1,
                "sugar": 1,
                "coffee": 1,
                "tea": 0,
                "juice": 0
            ]
        }
        
        return InventorySnapshot(
            timestamp: Date(),
            source: .pantryScan,
            itemQuantities: detectedItems,
            rawPayload: "Vision + CoreML confidence > 94.8%"
        )
    }
    
    public func resetScanSequence() {
        scanCount = 0
    }
}
