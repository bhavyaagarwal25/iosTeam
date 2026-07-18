//
//  PantryScannerService.swift
//  Blinkit Home Inventory AI
//
//  Orchestrates the Pantry Scan workflow:
//  Camera Open -> Image Capture -> Scanning Animation -> Vision AI Detection -> Pantry Inventory Generation.
//

import Foundation
import UIKit
import Combine

public enum ScanStage: Equatable {
    case idle
    case cameraActive
    case capturing
    case scanningAnimation(progress: Double)
    case analyzingVision
    case completed(InventorySnapshot)
    case failed(String)
}

@MainActor
public final class PantryScannerService: ObservableObject {
    public static let shared = PantryScannerService()
    
    @Published public private(set) var currentStage: ScanStage = .idle
    @Published public private(set) var lastCapturedImage: UIImage? = nil
    @Published public private(set) var latestPantrySnapshot: InventorySnapshot? = nil
    
    private let visionService: VisionServiceProtocol
    
    public init(visionService: VisionServiceProtocol = MockVisionService.shared) {
        self.visionService = visionService
    }
    
    /// Executes full scanning pipeline:
    /// User presses Scan Pantry -> Camera Opens -> Capture Image -> Scanning Animation -> Vision Detection -> Pantry Inventory Generated
    public func startScanPipeline(capturedImage: UIImage? = nil) async {
        currentStage = .cameraActive
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        currentStage = .capturing
        let sampleImage = capturedImage ?? UIImage(systemName: "camera.viewfinder")
        self.lastCapturedImage = sampleImage
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Scanning Animation Phase (0% to 100%)
        for percent in stride(from: 0.0, through: 1.0, by: 0.25) {
            currentStage = .scanningAnimation(progress: percent)
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        
        currentStage = .analyzingVision
        
        do {
            // Use Apple Vision Framework (VNRecognizeTextRequest / VNImageRequestHandler)
            let snapshot = try await VisionPantryAnalyzer.shared.analyzePantryPhoto(sampleImage)
            self.latestPantrySnapshot = snapshot
            self.currentStage = .completed(snapshot)
            BlinkitTheme.triggerNotificationHaptic(.success)
        } catch {
            self.currentStage = .failed(error.localizedDescription)
            BlinkitTheme.triggerNotificationHaptic(.error)
        }
    }
    
    public func resetScanner() {
        currentStage = .idle
        lastCapturedImage = nil
        latestPantrySnapshot = nil
    }
}
