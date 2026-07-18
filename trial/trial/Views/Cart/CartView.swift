//
//  CartView.swift
//  BlinkitFlow
//
//  Pixel-accurate rebuild from Figma node 1:86
//

import SwiftUI

@MainActor
public struct CartView: View {
    @StateObject private var viewModel: CartViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: CartViewModel())
    }

    public init(viewModel: CartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if viewModel.cartService.items.isEmpty {
                            // ── EMPTY STATE (Figma: y:160–420) ──
                            emptyStateSection

                            // ── BESTSELLERS (Figma: y:420–650) ──
                            bestsellersSection
                        } else {
                            deliveryBanner
                            cartItemsSection
                            billDetailsSection
                        }

                        Spacer().frame(height: 100)
                    }
                }

                if !viewModel.cartService.items.isEmpty {
                    checkoutFooterBar
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .overlay(alignment: .top) {
                cartHeader
            }
            .navigationDestination(isPresented: $viewModel.showCheckout) {
                CheckoutView()
            }
        }
    }

    // MARK: – Shared Header (same as Home screen per Figma)
    private var cartHeader: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Color(red: 0.1, green: 0.57, blue: 0.25)
                    .frame(height: 110)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Blinkit in")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 52)
                        .padding(.leading, 16)

                    HStack(spacing: 4) {
                        Text("16 minutes")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 2)

                    HStack(spacing: 4) {
                        Text("HOME")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("- Sujal Dave, Ratanada, Jodhpur (Raj)")
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

            // Search Bar
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
            .padding(.horizontal, 16)
            .padding(.top, -4)
            .padding(.bottom, 12)
            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
        }
        .padding(.top, 0)
    }

    // MARK: – Empty State (Figma: "Reordering will be easy" centered at y:328)
    private var emptyStateSection: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 168) // Push below header

            // Cart icon placeholder (no specific icon in Figma, just centered text)
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundColor(Color.gray.opacity(0.4))
                .padding(.bottom, 24)

            // "Reordering will be easy" — Figma x:96, y:328, w:184, h:24 — bold, centered
            Text("Reordering will be easy")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Subtitle — Figma x:66, y:352, w:234, h:30
            Text("Items you order will show up here so you can buy them again easily.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 66)
                .padding(.top, 8)
        }
    }

    // MARK: – Bestsellers Section (Figma: y:420+, "Bestsellers" header + 3 cards)
    private var bestsellersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Bestsellers" header — Figma x:15, y:420, w:85, h:24
            Text("Bestsellers")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 15)
                .padding(.top, 28)
                .padding(.bottom, 12)

            // 3 product cards — Figma: 96×108pt each
            HStack(spacing: 15) {
                bestsellerCard(
                    imageName: "bestseller_products",
                    name: "Amul Taaza Toned\nFresh Milk",
                    price: "27",
                    mins: "16 MINS"
                )
                bestsellerCard(
                    imageName: "bestseller_products",
                    name: "Potato (Aloo)",
                    price: "37",
                    mins: "16 MINS"
                )
                bestsellerCard(
                    imageName: "bestseller_products",
                    name: "Hybrid Tomato",
                    price: "37",
                    mins: "16 MINS"
                )
            }
            .padding(.horizontal, 15)
        }
    }

    private func bestsellerCard(imageName: String, name: String, price: String, mins: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image 96×108pt with ADD button bottom-right
            ZStack(alignment: .bottomTrailing) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 108)
                    .clipped()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)

                // ADD button — Figma: 30×18pt
                Button(action: {}) {
                    Text("ADD")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        .frame(width: 52, height: 26)
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(red: 0.1, green: 0.57, blue: 0.25), lineWidth: 1.5)
                        )
                }
                .padding(6)
            }
            .frame(width: 96, height: 108)

            // Product name
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(2)
                .frame(width: 96, alignment: .leading)
                .padding(.top, 5)

            // Timer — Figma: 16 MINS
            HStack(spacing: 3) {
                Image(systemName: "timer")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Text(mins)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 3)

            // Price — Figma: 27, 37, 37
            HStack(spacing: 2) {
                Image(systemName: "indianrupeesign")
                    .font(.system(size: 11, weight: .bold))
                Text(price)
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundColor(.primary)
            .padding(.top, 2)
        }
        .frame(width: 96)
    }

    // MARK: – Delivery Banner (when cart has items)
    private var deliveryBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.badge.checkmark.fill")
                .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text("Delivery in 16 minutes")
                    .font(.system(size: 14, weight: .bold))
                Text("Shipment of \(viewModel.cartService.totalItemCount) items")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(red: 0.1, green: 0.57, blue: 0.25).opacity(0.1))
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .padding(.top, 168) // push below header
    }

    private var cartItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cart Items")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(viewModel.cartService.items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .frame(width: 50, height: 50)
                            Image(systemName: item.product.systemImage)
                                .font(.system(size: 22))
                                .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.product.name)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                            Text(item.product.unit)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("₹\(Int(item.totalCost))")
                                .font(.system(size: 14, weight: .bold))
                        }

                        Spacer()

                        QuantityStepperView(
                            quantity: item.quantity,
                            onIncrement: { viewModel.updateQuantity(item: item, delta: 1) },
                            onDecrement: { viewModel.updateQuantity(item: item, delta: -1) }
                        )
                    }
                    .padding(12)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var billDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bill Details")
                .font(.system(size: 16, weight: .bold))

            VStack(spacing: 8) {
                HStack {
                    Text("Items Total").foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.itemTotal))").fontWeight(.semibold)
                }
                HStack {
                    Text("Delivery Charge").foregroundColor(.secondary)
                    Spacer()
                    if viewModel.cartService.deliveryFee == 0 {
                        Text("FREE").font(.system(size: 13, weight: .bold)).foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                    } else {
                        Text("₹\(Int(viewModel.cartService.deliveryFee))").fontWeight(.semibold)
                    }
                }
                Divider()
                HStack {
                    Text("Grand Total").font(.system(size: 16, weight: .black))
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.grandTotal))").font(.system(size: 16, weight: .black)).foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                }
            }
            .font(.system(size: 13))
            .padding(14)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var checkoutFooterBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("₹\(Int(viewModel.cartService.grandTotal))")
                    .font(.system(size: 18, weight: .black))
                Text("TOTAL BILL")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                viewModel.showCheckout = true
                BlinkitTheme.triggerHaptic(.medium)
            }) {
                HStack(spacing: 8) {
                    Text("Proceed to Checkout")
                        .font(.system(size: 15, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(red: 0.1, green: 0.57, blue: 0.25))
                .cornerRadius(14)
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
    }
}
