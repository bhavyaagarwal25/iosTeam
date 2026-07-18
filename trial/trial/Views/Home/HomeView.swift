//
//  HomeView.swift
//  BlinkitFlow
//
//  Premium iOS Native UI Rebuild
//

import SwiftUI

@MainActor
public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedProductForDetail: Product? = nil
    @State private var navigateToSearch: Bool = false
    @State private var navigateToCart: Bool = false

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
            VStack(spacing: 0) {
                // Sticky Header
                blinkitHeader

                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            diwaliSaleSection
                            productCardsSection
                            grocerySection
                            Spacer().frame(height: 90)
                        }
                    }
                    .refreshable { await viewModel.loadData() }

                    // Floating Cart Bar
                    if viewModel.cartService.totalItemCount > 0 {
                        floatingCartBar
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSearch) { SearchView() }
            .navigationDestination(isPresented: $navigateToCart) { CartView() }
            .sheet(item: $selectedProductForDetail) { product in
                ProductDetailView(product: product)
            }
        }
    }

    // MARK: – Header
    private var blinkitHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blinkit in")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 4) {
                        Text("16 minutes")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 4) {
                        Text("HOME")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("- Sujal Dave, Ratanada, Jodhpur (Raj)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Search Bar
            Button(action: { navigateToSearch = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .medium))
                    Text("Search \"ice-cream\"")
                        .foregroundColor(Color.gray.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Divider()
                        .frame(height: 20)
                    Image(systemName: "mic.fill")
                        .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        .font(.system(size: 18))
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 10)
        .background(
            Color(red: 0.1, green: 0.57, blue: 0.25)
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: – Mega Diwali Sale
    private var diwaliSaleSection: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.8, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mega Diwali Sale")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.5, green: 0.1, blue: 0.0))
                            .shadow(color: .white.opacity(0.5), radius: 1, x: 1, y: 1)

                        Text("Upto 60% OFF on festive picks")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.0))
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 4, x: 0, y: 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .frame(height: 90)

            // Sub-categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    diwaliCategoryTile(label: "Lights & Diyas", icon: "flame.fill", color: .orange)
                    diwaliCategoryTile(label: "Diwali Gifts", icon: "gift.fill", color: .purple)
                    diwaliCategoryTile(label: "Appliances", icon: "lightbulb.fill", color: .blue)
                    diwaliCategoryTile(label: "Home & Living", icon: "house.fill", color: .green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.white)
        }
    }

    private func diwaliCategoryTile(label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
    }

    // MARK: – Product Cards
    private var productCardsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    productCard(
                        icon: "flame.fill", color: .orange,
                        name: "Golden Glass Candle", price: "79", mins: "16 MINS"
                    )
                    productCard(
                        icon: "circle.grid.2x2.fill", color: .brown,
                        name: "Royal Gulab Jamun", price: "175", mins: "16 MINS"
                    )
                    productCard(
                        icon: "bag.fill", color: .red,
                        name: "Bikaji Bhujia", price: "110", mins: "16 MINS"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.white)
            .padding(.top, 8)
        }
    }

    private func productCard(icon: String, color: Color, name: String, price: String, mins: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image area
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(color)
                    .position(x: 60, y: 50)
                
                Button(action: {}) {
                    Text("ADD")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        .frame(width: 60, height: 32)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding(8)
            }
            .frame(width: 120, height: 120)

            Text(name)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 10))
                Text(mins)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(4)

            Text("₹\(price)")
                .font(.system(size: 16, weight: .black))
                .padding(.top, 2)
        }
        .frame(width: 120)
    }

    // MARK: – Grocery & Kitchen Section
    private var grocerySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Grocery & Kitchen")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    groceryCategoryTile(label: "Vegetables\n& Fruits", icon: "leaf.fill", color: .green)
                    groceryCategoryTile(label: "Atta, Dal\n& Rice", icon: "takeoutbox.fill", color: .brown)
                    groceryCategoryTile(label: "Oil, Ghee\n& Masala", icon: "drop.fill", color: .yellow)
                    groceryCategoryTile(label: "Dairy, Bread\n& Milk", icon: "cup.and.saucer.fill", color: .blue)
                    groceryCategoryTile(label: "Biscuits\n& Bakery", icon: "birthday.cake.fill", color: .pink)
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .padding(.top, 8)
    }

    private func groceryCategoryTile(label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
    }

    // MARK: – Floating Cart Bar
    private var floatingCartBar: some View {
        Button(action: {
            navigateToCart = true
            BlinkitTheme.triggerHaptic(.medium)
        }) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Text("\(viewModel.cartService.totalItemCount)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("₹\(Int(viewModel.cartService.grandTotal))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("TOTAL BILL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    Text("View Cart")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
            .cornerRadius(16)
            .shadow(color: Color(red: 0.1, green: 0.57, blue: 0.25).opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}
