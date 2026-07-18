//
//  InventoryItem.swift
//  Blinkit Home Inventory AI
//
//  Represents a single grocery item tracked in the Home Inventory.
//

import Foundation

/// Defines the stock status of an inventory item based on its current quantity and minimum threshold.
public enum InventoryStatus: String, Codable, CaseIterable, Hashable {
    case available = "Available"
    case low = "Low"
    case missing = "Missing"
    
    public var iconName: String {
        switch self {
        case .available: return "checkmark.seal.fill"
        case .low: return "exclamationmark.triangle.fill"
        case .missing: return "xmark.octagon.fill"
        }
    }
    
    public var badgeColorName: String {
        switch self {
        case .available: return "brandGreen"
        case .low: return "orange"
        case .missing: return "red"
        }
    }
}

/// Represents an item stored in the home inventory.
public struct InventoryItem: Identifiable, Codable, Hashable {
    public let id: String
    public var name: String
    public var currentQuantity: Int
    public var minimumThreshold: Int
    public var lastUpdated: Date
    public var category: ProductCategory
    public var unit: String
    public var productId: String?
    
    /// LOW INVENTORY RULE:
    /// - If currentQuantity == 0 -> Status = Missing
    /// - If currentQuantity <= minimumThreshold -> Status = Low
    /// - Otherwise -> Status = Available
    public var status: InventoryStatus {
        if currentQuantity == 0 {
            return .missing
        } else if currentQuantity <= minimumThreshold {
            return .low
        } else {
            return .available
        }
    }
    
    public var isLowOrMissing: Bool {
        return status == .low || status == .missing
    }
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        currentQuantity: Int,
        minimumThreshold: Int = 1,
        lastUpdated: Date = Date(),
        category: ProductCategory = .dairy,
        unit: String = "pcs",
        productId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.currentQuantity = currentQuantity
        self.minimumThreshold = minimumThreshold
        self.lastUpdated = lastUpdated
        self.category = category
        self.unit = unit
        self.productId = productId
    }
}
