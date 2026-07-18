//
//  HomeView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedProductForDetail: Product? = nil
    @State private var navigateToSearch: Bool = false
    @State private var navigateToCart: Bool = false
    @State private var showPantryScanner: Bool = false
    @State private var showFridgeScanner: Bool = false
    
    public var onRedirectToCart: (() -> Void)? = nil
    
    public init(onRedirectToCart: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
        self.onRedirectToCart = onRedirectToCart
    }
    
    public init(viewModel: HomeViewModel, onRedirectToCart: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onRedirectToCart = onRedirectToCart
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Top Header (Delivery Address & Profile)
                        headerView
                        
                        // Search Bar Button
                        searchBarButton
                        
                        // Smart Fridge IoT & Pantry Vision AI Scanners
                        aiScannersSection
                        
                        // Time-of-Day Context Greeting Banner
                        contextBannerView
                        
                        // Category Scroll View
                        CategoryCarouselView(
                            selectedCategory: $viewModel.selectedCategory,
                            onSelectCategory: { cat in
                                Task {
                                    await viewModel.filter(by: cat)
                                }
                            }
                        )
                        
                        // Recommended for You (Context driven)
                        if !viewModel.contextInfo.recommendedProducts.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Recommended for You")
                                        .font(.system(size: 18, weight: .bold))
                                    Spacer()
                                    Text("Smart Context")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(BlinkitTheme.brandGreen)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(BlinkitTheme.brandGreenLight)
                                        .cornerRadius(6)
                                }
                                .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.contextInfo.recommendedProducts) { product in
                                            ProductCardView(
                                                product: product,
                                                cartQuantity: getQuantity(for: product),
                                                onAdd: { viewModel.cartService.addToCart(product: product) },
                                                onIncrement: { viewModel.cartService.addToCart(product: product) },
                                                onDecrement: { updateQty(product: product, delta: -1) }
                                            )
                                            .frame(width: 155)
                                            .onTapGesture {
                                                selectedProductForDetail = product
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // All Products Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text(viewModel.selectedCategory == .all ? "All Groceries" : viewModel.selectedCategory.rawValue)
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                ForEach(viewModel.products) { product in
                                    ProductCardView(
                                        product: product,
                                        cartQuantity: getQuantity(for: product),
                                        onAdd: { viewModel.cartService.addToCart(product: product) },
                                        onIncrement: { viewModel.cartService.addToCart(product: product) },
                                        onDecrement: { updateQty(product: product, delta: -1) }
                                    )
                                    .onTapGesture {
                                        selectedProductForDetail = product
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Bottom spacer for floating cart
                        Spacer().frame(height: 90)
                    }
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.loadData()
                }
                
                // Persistent Floating Cart Bar
                if viewModel.cartService.totalItemCount > 0 {
                    floatingCartBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView()
            }
            .navigationDestination(isPresented: $navigateToCart) {
                CartView()
            }
            .sheet(item: $selectedProductForDetail) { product in
                ProductDetailView(product: product)
            }
            .sheet(isPresented: $showPantryScanner) {
                PantryScannerView()
            }
            .sheet(isPresented: $showFridgeScanner) {
                SmartFridgeScannerView(onRedirectToCart: {
                    onRedirectToCart?()
                })
            }
        }
    }
    
    // AI Inventory Scanners (Smart Fridge IoT + Pantry Vision AI)
    private var aiScannersSection: some View {
        HStack(spacing: 12) {
            // Button 1: Smart Fridge IoT
            Button(action: {
                showFridgeScanner = true
                BlinkitTheme.triggerHaptic(.medium)
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "snowflake")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Smart Fridge")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("IoT Auto-Scan")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Button 2: Pantry Vision AI
            Button(action: {
                showPantryScanner = true
                BlinkitTheme.triggerHaptic(.medium)
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(BlinkitTheme.brandGreen.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pantry Scan")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Vision Kit AI")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(BlinkitTheme.brandGreen.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(BlinkitTheme.yellow)
                        .font(.system(size: 16, weight: .bold))
                    Text("10 MINS")
                        .font(.system(size: 16, weight: .black))
                }
                
                HStack(spacing: 4) {
                    Text("Home - Flat 402, Sunshine Heights...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Profile icon
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 34, height: 34)
                .foregroundColor(BlinkitTheme.brandGreen)
        }
        .padding(.horizontal, 16)
    }
    
    // Search Bar Button
    private var searchBarButton: some View {
        Button(action: {
            navigateToSearch = true
            BlinkitTheme.triggerHaptic(.light)
        }) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .semibold))
                Text("Search 'Amul milk', 'Maggi', 'Atta'...")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                Spacer()
                Image(systemName: "mic.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
    
    // Context Greeting Banner
    private var contextBannerView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.contextInfo.greetingTitle)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(BlinkitTheme.textPrimaryLight)
                Text(viewModel.contextInfo.greetingSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BlinkitTheme.textSecondaryLight)
            }
            Spacer()
            
            Image(systemName: viewModel.contextInfo.bannerIcon)
                .font(.system(size: 32))
                .foregroundColor(BlinkitTheme.brandGreen)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [BlinkitTheme.yellow.opacity(0.35), BlinkitTheme.yellow.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(BlinkitTheme.yellow.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    // Floating Cart Bar
    private var floatingCartBar: some View {
        Button(action: {
            navigateToCart = true
            BlinkitTheme.triggerHaptic(.medium)
        }) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 32, height: 32)
                        Text("\(viewModel.cartService.totalItemCount)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("₹\(Int(viewModel.cartService.grandTotal))")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("TOTAL BILL")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("View Cart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(BlinkitTheme.brandGreen)
            .cornerRadius(16)
            .shadow(color: BlinkitTheme.brandGreen.opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
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
