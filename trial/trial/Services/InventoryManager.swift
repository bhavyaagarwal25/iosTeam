//
//  InventoryManager.swift
//  Blinkit Home Inventory AI
//
//  Central manager for maintaining and merging the home inventory across Smart Fridge (IoT)
//  and Pantry Scan (Vision AI). Evaluates Low/Missing status, syncs with Cart without duplicates,
//  restocks inventory upon order placement, and persists state locally.
//

import Foundation
import Combine

@MainActor
public final class InventoryManager: ObservableObject {
    public static let shared = InventoryManager()
    
    @Published public private(set) var items: [InventoryItem] = []
    @Published public private(set) var lastMergedSnapshot: InventorySnapshot? = nil
    @Published public private(set) var isSyncing: Bool = false
    
    private let iotService: IoTServiceProtocol
    private let visionService: VisionServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    
    public init(
        iotService: IoTServiceProtocol = MockIoTService.shared,
        visionService: VisionServiceProtocol = MockVisionService.shared,
        persistenceService: PersistenceServiceProtocol = PersistenceService.shared
    ) {
        self.iotService = iotService
        self.visionService = visionService
        self.persistenceService = persistenceService
        
        loadInitialInventory()
    }
    
    // MARK: - Initial Inventory Setup & Local Persistence
    
    private func loadInitialInventory() {
        // Always start from defaults to avoid stale data from old sessions (hackathon demo)
        self.items = defaultHomeInventory()
        persistenceService.saveInventory(self.items)
    }
    
    /// 12 home inventory items with Icecream, Fruits, Vegetables, Sauce, Dahi, Jam.
    public func defaultHomeInventory() -> [InventoryItem] {
        return [
            InventoryItem(name: "milk", currentQuantity: 0, minimumThreshold: 1, category: .dairy, unit: "500 ml", productId: "p1"),
            InventoryItem(name: "butter", currentQuantity: 0, minimumThreshold: 1, category: .dairy, unit: "100 g", productId: "p2"),
            InventoryItem(name: "cheese", currentQuantity: 0, minimumThreshold: 1, category: .dairy, unit: "200 g", productId: "p5"),
            InventoryItem(name: "bread", currentQuantity: 1, minimumThreshold: 1, category: .dairy, unit: "400 g", productId: "p3"),
            InventoryItem(name: "eggs", currentQuantity: 2, minimumThreshold: 4, category: .dairy, unit: "6 pcs", productId: "p10"),
            InventoryItem(name: "juice", currentQuantity: 1, minimumThreshold: 2, category: .beverages, unit: "1 L", productId: "p20"),
            InventoryItem(name: "icecream", currentQuantity: 0, minimumThreshold: 1, category: .dairy, unit: "500 ml", productId: "p101"),
            InventoryItem(name: "fruits", currentQuantity: 2, minimumThreshold: 1, category: .fruitsVeg, unit: "1 kg", productId: "p102"),
            InventoryItem(name: "vegetables", currentQuantity: 3, minimumThreshold: 1, category: .fruitsVeg, unit: "1 kg", productId: "p103"),
            InventoryItem(name: "sauce", currentQuantity: 1, minimumThreshold: 1, category: .snacks, unit: "500 g", productId: "p104"),
            InventoryItem(name: "dahi", currentQuantity: 0, minimumThreshold: 1, category: .dairy, unit: "400 g", productId: "p105"),
            InventoryItem(name: "jam", currentQuantity: 1, minimumThreshold: 1, category: .snacks, unit: "500 g", productId: "p106")
        ]
    }
    
    // MARK: - Core Inventory Merging Pipeline
    
    /// Merges Pantry Scan + Smart Fridge Inventory into unified Home Inventory.
    public func processFullInventoryScan(pantrySnapshot: InventorySnapshot) async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // 1. Fetch Smart Fridge IoT Snapshot
            let fridgeSnapshot = try await iotService.fetchSmartFridgeSnapshot()
            
            // 2. Merge Smart Fridge + Pantry Scan item quantities
            var mergedMap: [String: Int] = fridgeSnapshot.itemQuantities
            for (itemKey, qty) in pantrySnapshot.itemQuantities {
                mergedMap[itemKey.lowercased()] = qty
            }
            
            let mergedSnapshot = InventorySnapshot(
                timestamp: Date(),
                source: .merged,
                itemQuantities: mergedMap,
                rawPayload: "Fridge IoT + Pantry Vision Merged"
            )
            self.lastMergedSnapshot = mergedSnapshot
            persistenceService.saveLastScan(mergedSnapshot)
            
            // 3. Update Home Inventory items based on merged snapshot
            for (key, qty) in mergedMap {
                if let index = items.firstIndex(where: { $0.name.lowercased() == key.lowercased() }) {
                    items[index].currentQuantity = qty
                    items[index].lastUpdated = Date()
                }
            }
            
            // 4. Save updated Home Inventory
            saveInventory()
            
            // 5. Identify Low & Missing products and update Cart (deduplicated)
            syncLowAndMissingToCart(from: mergedSnapshot)
            
        } catch {
            print("❌ InventoryManager: Failed to process inventory scan: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Auto Cart Rules & Deduplication
    
    /// Identifies items with Status == .low or .missing and adds them to CartService without duplicates.
    public func syncLowAndMissingToCart(from snapshot: InventorySnapshot? = nil) {
        let itemsToCheck: [InventoryItem]
        if let snapshot = snapshot {
            itemsToCheck = items.filter { item in
                snapshot.itemQuantities.keys.contains(item.name.lowercased()) && item.isLowOrMissing
            }
        } else {
            itemsToCheck = items.filter { $0.isLowOrMissing }
        }
        
        let cart = CartService.shared
        let catalog = MockData.sampleProducts
        
        for item in itemsToCheck {
            if let product = catalog.first(where: { p in
                p.id == item.productId || p.name.lowercased() == item.name.lowercased()
            }) {
                let alreadyInCart = cart.items.contains(where: { $0.product.id == product.id })
                if !alreadyInCart {
                    cart.addToCart(product: product, quantity: 1)
                }
            }
        }
    }
    
    // MARK: - Order Restocking Flow
    
    /// Called after Place Order succeeds. Restocks items in Home Inventory and saves state.
    public func restockOrderedItems(orderedItems: [CartItem]) {
        for cartItem in orderedItems {
            let productName = cartItem.product.name.lowercased()
            
            if let index = items.firstIndex(where: { item in
                productName.contains(item.name.lowercased()) || item.name.lowercased().contains(productName)
            }) {
                let restockQty: Int
                switch items[index].name.lowercased() {
                case "milk": restockQty = 2
                case "eggs": restockQty = 10
                case "butter": restockQty = 2
                case "cheese": restockQty = 2
                case "icecream": restockQty = 2
                case "dahi": restockQty = 2
                case "fruits": restockQty = 2
                case "vegetables": restockQty = 2
                case "sauce": restockQty = 2
                case "jam": restockQty = 2
                case "juice": restockQty = 3
                default: restockQty = max(cartItem.quantity, 2)
                }
                
                items[index].currentQuantity += restockQty
                items[index].lastUpdated = Date()
            }
        }
        
        saveInventory()
        
        // Sync restocked inventory telemetry to MockIoTService so IoT fridge scans reflect new stock
        MockIoTService.shared.updateFridgeTelemetry(with: self.items)
    }
    
    // MARK: - Helper Methods
    
    public func saveInventory() {
        persistenceService.saveInventory(self.items)
    }
    
    public func resetInventoryToDefaults() {
        self.items = defaultHomeInventory()
        saveInventory()
        MockIoTService.shared.resetTelemetryToDefaults()
    }
}
