//
//  PersistenceService.swift
//  Blinkit Home Inventory AI
//
//  Handles local persistence using UserDefaults and JSONEncoder/JSONDecoder.
//  Persists Home Inventory, Cart, Last Scan snapshot, and Last Order.
//

import Foundation

public protocol PersistenceServiceProtocol {
    func saveInventory(_ items: [InventoryItem])
    func loadInventory() -> [InventoryItem]?
    
    func saveCartItems(_ items: [CartItem])
    func loadCartItems() -> [CartItem]?
    
    func saveLastScan(_ snapshot: InventorySnapshot)
    func loadLastScan() -> InventorySnapshot?
    
    func saveLastOrder(_ order: Order)
    func loadLastOrder() -> Order?
    
    func clearAllData()
}

public final class PersistenceService: PersistenceServiceProtocol {
    public static let shared = PersistenceService()
    
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private enum Keys {
        static let inventory = "blinkit_home_inventory_v1"
        static let cart = "blinkit_cart_items_v1"
        static let lastScan = "blinkit_last_scan_snapshot_v1"
        static let lastOrder = "blinkit_last_order_v1"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Inventory Persistence
    
    public func saveInventory(_ items: [InventoryItem]) {
        do {
            let data = try encoder.encode(items)
            userDefaults.set(data, forKey: Keys.inventory)
        } catch {
            print("❌ PersistenceService: Failed to save inventory: \(error.localizedDescription)")
        }
    }
    
    public func loadInventory() -> [InventoryItem]? {
        guard let data = userDefaults.data(forKey: Keys.inventory) else { return nil }
        do {
            return try decoder.decode([InventoryItem].self, from: data)
        } catch {
            print("❌ PersistenceService: Failed to decode inventory: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Cart Persistence
    
    public func saveCartItems(_ items: [CartItem]) {
        do {
            let data = try encoder.encode(items)
            userDefaults.set(data, forKey: Keys.cart)
        } catch {
            print("❌ PersistenceService: Failed to save cart items: \(error.localizedDescription)")
        }
    }
    
    public func loadCartItems() -> [CartItem]? {
        guard let data = userDefaults.data(forKey: Keys.cart) else { return nil }
        do {
            return try decoder.decode([CartItem].self, from: data)
        } catch {
            print("❌ PersistenceService: Failed to decode cart items: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Last Scan Persistence
    
    public func saveLastScan(_ snapshot: InventorySnapshot) {
        do {
            let data = try encoder.encode(snapshot)
            userDefaults.set(data, forKey: Keys.lastScan)
        } catch {
            print("❌ PersistenceService: Failed to save last scan: \(error.localizedDescription)")
        }
    }
    
    public func loadLastScan() -> InventorySnapshot? {
        guard let data = userDefaults.data(forKey: Keys.lastScan) else { return nil }
        do {
            return try decoder.decode(InventorySnapshot.self, from: data)
        } catch {
            print("❌ PersistenceService: Failed to decode last scan: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Last Order Persistence
    
    public func saveLastOrder(_ order: Order) {
        do {
            let data = try encoder.encode(order)
            userDefaults.set(data, forKey: Keys.lastOrder)
        } catch {
            print("❌ PersistenceService: Failed to save last order: \(error.localizedDescription)")
        }
    }
    
    public func loadLastOrder() -> Order? {
        guard let data = userDefaults.data(forKey: Keys.lastOrder) else { return nil }
        do {
            return try decoder.decode(Order.self, from: data)
        } catch {
            print("❌ PersistenceService: Failed to decode last order: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Utility
    
    public func clearAllData() {
        userDefaults.removeObject(forKey: Keys.inventory)
        userDefaults.removeObject(forKey: Keys.cart)
        userDefaults.removeObject(forKey: Keys.lastScan)
        userDefaults.removeObject(forKey: Keys.lastOrder)
    }
}
