//
//  HomeViewModel.swift
//  BlinkitFlow
//

import Foundation
import Combine

@MainActor
public class HomeViewModel: ObservableObject {
    @Published public var selectedCategory: ProductCategory = .all
    @Published public var products: [Product] = []
    @Published public var popularProducts: [Product] = []
    @Published public var contextInfo: ContextInfo
    @Published var isLoading: Bool = false
    @Published public var searchText: String = ""
    
    private let productService: ProductServiceProtocol
    private let contextEngine: ContextEngineService
    public let cartService: CartService
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.productService = MockProductService.shared
        self.contextEngine = ContextEngineService.shared
        self.cartService = CartService.shared
        self.contextInfo = ContextEngineService.shared.getCurrentContext()
        
        setupSubscriptions()
        Task {
            await loadData()
        }
    }
    
    public init(
        productService: ProductServiceProtocol,
        contextEngine: ContextEngineService,
        cartService: CartService
    ) {
        self.productService = productService
        self.contextEngine = contextEngine
        self.cartService = cartService
        self.contextInfo = contextEngine.getCurrentContext()
        
        setupSubscriptions()
        Task {
            await loadData()
        }
    }
    
    private func setupSubscriptions() {
        cartService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public func loadData() async {
        isLoading = true
        let allProds = await productService.fetchProducts()
        self.products = allProds
        self.popularProducts = allProds.filter { $0.isPopular }
        self.contextInfo = contextEngine.getCurrentContext()
        isLoading = false
    }
    
    public func filter(by category: ProductCategory) async {
        self.selectedCategory = category
        if category == .all {
            self.products = await productService.fetchProducts()
        } else {
            self.products = await productService.fetchProducts(by: category)
        }
    }
}
