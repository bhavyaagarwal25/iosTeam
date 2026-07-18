//
//  ProductService.swift
//  BlinkitFlow
//

import Foundation

public protocol ProductServiceProtocol {
    func fetchProducts() async -> [Product]
    func fetchProducts(by category: ProductCategory) async -> [Product]
    func searchProducts(query: String) async -> [Product]
    func fetchPopularProducts() async -> [Product]
}

public class MockProductService: ProductServiceProtocol {
    public static let shared = MockProductService()
    
    private let products: [Product] = MockData.sampleProducts
    
    public init() {}
    
    public func fetchProducts() async -> [Product] {
        // Simulate minor async delay for realistic feel
        try? await Task.sleep(nanoseconds: 100_000_000)
        return products
    }
    
    public func fetchProducts(by category: ProductCategory) async -> [Product] {
        if category == .all {
            return products
        }
        return products.filter { $0.category == category }
    }
    
    public func searchProducts(query: String) async -> [Product] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return products }
        let lower = query.lowercased()
        return products.filter {
            $0.name.lowercased().contains(lower) ||
            $0.category.rawValue.lowercased().contains(lower) ||
            $0.description.lowercased().contains(lower)
        }
    }
    
    public func fetchPopularProducts() async -> [Product] {
        return products.filter { $0.isPopular }
    }
}
