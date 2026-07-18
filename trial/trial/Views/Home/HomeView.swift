//
//  HomeView.swift
//  BlinkitFlow
//
//  Pixel-accurate rebuild from Figma node 1:2
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
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // ── HEADER (Figma: Rectangle 16, y:0–160) ──
                        blinkitHeader

                        // ── MEGA DIWALI SALE SECTION (y:160–356) ──
                        diwaliSaleSection

                        // ── PRODUCT CARDS (y:356–580) ──
                        productCardsSection

                        // ── GROCERY & KITCHEN SECTION (y:581–743) ──
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
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSearch) { SearchView() }
            .navigationDestination(isPresented: $navigateToCart) { CartView() }
            .sheet(item: $selectedProductForDetail) { product in
                ProductDetailView(product: product)
            }
        }
    }

    // MARK: – Header (Figma: 375×160pt green background)
    private var blinkitHeader: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Green background rectangle
                Color(red: 0.1, green: 0.57, blue: 0.25) // Blinkit brand green
                    .frame(height: 160)

                VStack(alignment: .leading, spacing: 0) {
                    // "Blinkit in" label
                    Text("Blinkit in")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 52)
                        .padding(.leading, 16)

                    // "16 minutes" ETA
                    HStack(spacing: 4) {
                        Text("16 minutes")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading, 16)
                    .padding(.top, 2)

                    // Address row
                    HStack(spacing: 4) {
                        Text("HOME")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("-")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Text("Sujal Dave, Ratanada, Jodhpur (Raj)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.leading, 16)
                    .padding(.top, 4)
                }

                // Profile Avatar (top-right)
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 55)
                }
            }
            .frame(height: 110)

            // Search Bar (Figma: 346×37pt at y:98)
            Button(action: { navigateToSearch = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                    Text("Search \"ice-cream\"")
                        .foregroundColor(Color(.placeholderText))
                        .font(.system(size: 14))
                    Spacer()
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 20)
                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                }
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, -4)
            .padding(.bottom, 12)
            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
        }
    }

    // MARK: – Mega Diwali Sale (Figma: Rectangle 50, 375×196pt)
    private var diwaliSaleSection: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Yellow/orange festive background
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.88, blue: 0.2), Color(red: 1.0, green: 0.75, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: 0) {
                    // "Mega Diwali Sale" header with Diwali banner image on right
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mega Diwali Sale")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(Color(red: 0.55, green: 0.27, blue: 0))

                            Text("Upto 60% OFF on festive picks")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.55, green: 0.27, blue: 0).opacity(0.8))
                        }
                        .padding(.top, 16)
                        .padding(.leading, 16)

                        Spacer()

                        // Diwali banner image on right (Figma: image 55, 56)
                        Image("diwali_banner")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 60)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                    }
                }
            }
            .frame(height: 90)

            // Diwali Sub-Category Cards (Figma: 4 cards, each 86×108pt)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    diwaliCategoryTile(label: "Lights, Diyas\n& Candles", bgColor: Color(red: 1.0, green: 0.92, blue: 0.8))
                    diwaliCategoryTile(label: "Diwali\nGifts", bgColor: Color(red: 0.95, green: 0.88, blue: 1.0))
                    diwaliCategoryTile(label: "Appliances\n& Gadgets", bgColor: Color(red: 0.85, green: 0.95, blue: 1.0))
                    diwaliCategoryTile(label: "Home\n& Living", bgColor: Color(red: 0.88, green: 1.0, blue: 0.88))
                }
            }
            .background(Color(uiColor: .systemBackground))

            Divider()
        }
    }

    private func diwaliCategoryTile(label: String, bgColor: Color) -> some View {
        VStack(spacing: 0) {
            ZStack {
                bgColor
                Image("diwali_banner")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 86, height: 76)
                    .clipped()
                    .opacity(0.35)
            }
            .frame(width: 86, height: 76)

            Spacer(minLength: 0)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
        }
        .frame(width: 86, height: 108)
        .background(bgColor)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: – Product Cards (Figma: 3 cards, each 93×108pt at y:379)
    private var productCardsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    productCard(
                        imageName: "diwali_products",
                        cropX: 0, cropFraction: 0.33,
                        name: "Golden Glass Wooden\nLid Candle (Oudh)",
                        price: "79",
                        mins: "16 MINS"
                    )
                    productCard(
                        imageName: "diwali_products",
                        cropX: 0.33, cropFraction: 0.34,
                        name: "Royal Gulab Jamun\nBy Bikano",
                        price: "79",
                        mins: "16 MINS"
                    )
                    productCard(
                        imageName: "diwali_products",
                        cropX: 0.67, cropFraction: 0.33,
                        name: "Bikaji Bhujia",
                        price: "79",
                        mins: "16 MINS"
                    )
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
            }
            Divider()
        }
        .background(Color(uiColor: .systemBackground))
    }

    private func productCard(imageName: String, cropX: CGFloat, cropFraction: CGFloat, name: String, price: String, mins: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image area (93×108pt) with ADD button overlaid
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { _ in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 93, height: 108)
                        .clipped()
                }
                .frame(width: 93, height: 108)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(8)

                // ADD button (Figma: 30×18pt, green border)
                Button(action: {}) {
                    Text("ADD")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        .frame(width: 56, height: 28)
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 0.1, green: 0.57, blue: 0.25), lineWidth: 1.5)
                        )
                }
                .padding(6)
            }
            .frame(width: 93, height: 108)

            // Product name
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(width: 93, alignment: .leading)
                .padding(.top, 6)

            // Timer row
            HStack(spacing: 3) {
                Image(systemName: "timer")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Text(mins)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 3)

            // Price row
            HStack(spacing: 2) {
                Image(systemName: "indianrupeesign")
                    .font(.system(size: 11, weight: .bold))
                Text(price)
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundColor(.primary)
            .padding(.top, 2)
        }
        .frame(width: 93)
    }

    // MARK: – Grocery & Kitchen Section (Figma: y:581–743)
    private var grocerySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Text("Grocery & Kitchen")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 15)
                .padding(.top, 14)
                .padding(.bottom, 10)

            // 5 category tiles in horizontal scroll (71×78pt each, Figma spacing)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    groceryCategoryTile(label: "Vegetables\n& Fruits", imageIndex: 0)
                    groceryCategoryTile(label: "Atta, Dal\n& Rice", imageIndex: 1)
                    groceryCategoryTile(label: "Oil, Ghee\n& Masala", imageIndex: 2)
                    groceryCategoryTile(label: "Dairy, Bread\n& Milk", imageIndex: 3)
                    groceryCategoryTile(label: "Biscuits\n& Bakery", imageIndex: 4)
                }
                .padding(.horizontal, 10)
            }
            .padding(.bottom, 12)

            Divider()
        }
        .background(Color(uiColor: .systemBackground))
    }

    private func groceryCategoryTile(label: String, imageIndex: Int) -> some View {
        VStack(spacing: 0) {
            // Image tile (71×78pt)
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .cornerRadius(8)
                Image("grocery_categories")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(6)
            }
            .frame(width: 71, height: 78)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
            )

            // Label
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 71)
                .padding(.top, 4)
        }
        .frame(width: 82)
    }

    // MARK: – Floating Cart Bar
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
            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
            .cornerRadius(16)
            .shadow(color: Color(red: 0.1, green: 0.57, blue: 0.25).opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    private func getQuantity(for product: Product) -> Int {
        viewModel.cartService.items.filter { $0.product.id == product.id }.reduce(0) { $0 + $1.quantity }
    }

    private func updateQty(product: Product, delta: Int) {
        if let item = viewModel.cartService.items.first(where: { $0.product.id == product.id }) {
            viewModel.cartService.updateQuantity(for: item.id, quantity: item.quantity + delta)
        }
    }
}
