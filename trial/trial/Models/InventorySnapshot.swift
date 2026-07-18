//
//  InventorySnapshot.swift
//  Blinkit Home Inventory AI
//
//  Captures a snapshot of inventory detection from IoT Smart Fridge or Vision Pantry Scan.
//

import Foundation

public enum InventorySource: String, Codable, CaseIterable, Hashable {
    case smartFridge = "Smart Fridge (IoT)"
    case pantryScan = "Pantry Scan (Vision AI)"
    case merged = "Merged Home Inventory"
}

/// A snapshot containing detected item quantities at a specific point in time.
public struct InventorySnapshot: Identifiable, Codable, Hashable {
    public let id: String
    public let timestamp: Date
    public let source: InventorySource
    /// Dictionary mapping standardized item names (e.g. "milk") to detected quantities
    public let itemQuantities: [String: Int]
    public let rawPayload: String?
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        source: InventorySource,
        itemQuantities: [String: Int],
        rawPayload: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.source = source
        self.itemQuantities = itemQuantities
        self.rawPayload = rawPayload
    }
}
