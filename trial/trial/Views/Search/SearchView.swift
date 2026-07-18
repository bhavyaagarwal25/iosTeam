//
//  SearchView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var selectedProduct: Product? = nil
    
    public init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    
    public init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Search Input Header
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search 'Amul', 'Maggi', 'Butter'...", text: $viewModel.searchQuery)
                        .font(.system(size: 15))
                        .onChange(of: viewModel.searchQuery) { _ in
                            Task {
                                await viewModel.performSearch()
                            }
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: viewModel.clearSearch) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            
            // Recent Searches Chips
            if viewModel.searchQuery.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Searches")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { term in
                                Button(action: {
                                    viewModel.selectRecentSearch(term)
                                    BlinkitTheme.triggerHaptic(.light)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 10))
                                        Text(term)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(uiColor: .tertiarySystemBackground))
                                    .cornerRadius(16)
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            
            // Results Count & Grid
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(viewModel.searchResults.count) Items Found")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(viewModel.searchResults) { product in
                            ProductCardView(
                                product: product,
                                cartQuantity: getQuantity(for: product),
                                onAdd: { viewModel.cartService.addToCart(product: product) },
                                onIncrement: { viewModel.cartService.addToCart(product: product) },
                                onDecrement: { updateQty(product: product, delta: -1) }
                            )
                            .onTapGesture {
                                selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 4)
            }
        }
        .navigationTitle("Search Groceries")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
    
    private func getQuantity(for product: Product) -> Int {
        viewModel.cartService.items
            .filter { $0.product.id == product.id }
            .reduce(0) { $0 + $1.quantity }
    }
    
    private func updateQty(product: Product, delta: Int) {
        if let item = viewModel.cartService.items.first(where: { $0.product.id == product.id }) {
            viewModel.cartService.updateQuantity(for: item.id, quantity: item.quantity + delta)
        }
    }
}
