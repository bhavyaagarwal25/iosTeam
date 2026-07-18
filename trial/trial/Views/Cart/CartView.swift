//
//  CartView.swift
//  BlinkitFlow
//
//  Premium iOS Native UI Rebuild
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
            VStack(spacing: 0) {
                cartHeader
                
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if viewModel.cartService.items.isEmpty {
                                emptyStateSection
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
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.showCheckout) {
                CheckoutView()
            }
        }
    }

    // MARK: – Shared Header
    private var cartHeader: some View {
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
            Button(action: {}) {
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

    // MARK: – Empty State
    private var emptyStateSection: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "cart")
                    .font(.system(size: 48))
                    .foregroundColor(Color.gray.opacity(0.4))
            }
            .padding(.bottom, 24)

            Text("Reordering will be easy")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text("Items you order will show up here so you can buy them again easily.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
                
            Spacer().frame(height: 40)
        }
    }

    // MARK: – Bestsellers Section
    private var bestsellersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Bestsellers")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    bestsellerCard(
                        icon: "drop.fill", color: .blue,
                        name: "Amul Taaza Toned Fresh Milk", price: "27", mins: "16 MINS"
                    )
                    bestsellerCard(
                        icon: "leaf.fill", color: .brown,
                        name: "Potato (Aloo)", price: "37", mins: "16 MINS"
                    )
                    bestsellerCard(
                        icon: "circle.circle.fill", color: .red,
                        name: "Hybrid Tomato", price: "37", mins: "16 MINS"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .padding(.top, 16)
        .background(Color.white)
    }

    private func bestsellerCard(icon: String, color: Color, name: String, price: String, mins: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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

    // MARK: – Cart Contents
    private var deliveryBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.checkmark.fill")
                .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                .font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text("Delivery in 16 minutes")
                    .font(.system(size: 16, weight: .bold))
                Text("Shipment of \(viewModel.cartService.totalItemCount) items")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(red: 0.1, green: 0.57, blue: 0.25).opacity(0.08))
        .cornerRadius(16)
        .padding(16)
    }

    private var cartItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cart Items")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)

            VStack(spacing: 16) {
                ForEach(viewModel.cartService.items) { item in
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .frame(width: 60, height: 60)
                            Image(systemName: item.product.systemImage)
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name)
                                .font(.system(size: 15, weight: .semibold))
                                .lineLimit(1)
                            Text(item.product.unit)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text("₹\(Int(item.totalCost))")
                                .font(.system(size: 16, weight: .bold))
                        }

                        Spacer()

                        QuantityStepperView(
                            quantity: item.quantity,
                            onIncrement: { viewModel.updateQuantity(item: item, delta: 1) },
                            onDecrement: { viewModel.updateQuantity(item: item, delta: -1) }
                        )
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var billDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bill Details")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 16)

            VStack(spacing: 12) {
                HStack {
                    Text("Items Total").foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.itemTotal))").fontWeight(.medium)
                }
                HStack {
                    Text("Delivery Charge").foregroundColor(.secondary)
                    Spacer()
                    if viewModel.cartService.deliveryFee == 0 {
                        Text("FREE").font(.system(size: 14, weight: .bold)).foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                    } else {
                        Text("₹\(Int(viewModel.cartService.deliveryFee))").fontWeight(.medium)
                    }
                }
                Divider().padding(.vertical, 4)
                HStack {
                    Text("Grand Total").font(.system(size: 18, weight: .black))
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.grandTotal))").font(.system(size: 18, weight: .black)).foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                }
            }
            .font(.system(size: 14))
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
    }

    private var checkoutFooterBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("₹\(Int(viewModel.cartService.grandTotal))")
                    .font(.system(size: 20, weight: .black))
                Text("TOTAL BILL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                viewModel.showCheckout = true
                BlinkitTheme.triggerHaptic(.medium)
            }) {
                HStack(spacing: 8) {
                    Text("Proceed to Checkout")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(red: 0.1, green: 0.57, blue: 0.25))
                .cornerRadius(16)
            }
        }
        .padding(16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -5)
    }
}
