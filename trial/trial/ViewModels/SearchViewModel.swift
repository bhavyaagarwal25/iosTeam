//
//  SearchViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine

@MainActor
public class SearchViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var searchResults: [Product] = []
    @Published public var recentSearches: [String] = ["Amul Milk", "Maggi", "Lay's", "Tomato 1kg", "Butter"]
    @Published public var selectedCategoryFilter: ProductCategory = .all
    
    private let productService: ProductServiceProtocol
    public let cartService: CartService
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.productService = MockProductService.shared
        self.cartService = CartService.shared
        
        setupSubscriptions()
        Task {
            await performSearch()
        }
    }
    
    public init(
        productService: ProductServiceProtocol,
        cartService: CartService
    ) {
        self.productService = productService
        self.cartService = cartService
        
        setupSubscriptions()
        Task {
            await performSearch()
        }
    }
    
    private func setupSubscriptions() {
        cartService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public func performSearch() async {
        if searchQuery.isEmpty && selectedCategoryFilter == .all {
            self.searchResults = await productService.fetchProducts()
        } else {
            var res = await productService.searchProducts(query: searchQuery)
            if selectedCategoryFilter != .all {
                res = res.filter { $0.category == selectedCategoryFilter }
            }
            self.searchResults = res
        }
    }
    
    public func selectRecentSearch(_ term: String) {
        self.searchQuery = term
        Task {
            await performSearch()
        }
    }
    
    public func clearSearch() {
        self.searchQuery = ""
        Task {
            await performSearch()
        }
    }
}
