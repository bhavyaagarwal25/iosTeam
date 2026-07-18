//
//  CartView.swift
//  BlinkitFlow
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
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Delivery ETA banner
                    deliveryBanner
                    
                    // Group Cart Entry Card
                    groupCartBanner
                    
                    if viewModel.cartService.items.isEmpty {
                        emptyCartView
                    } else {
                        // Cart Items List
                        cartItemsSection
                        
                        // Bill Details Breakdown
                        billDetailsSection
                    }
                    
                    // Saved Lists for 1-Tap Reorder
                    savedListsSection
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top, 12)
            }
            
            // Bottom Checkout Footer
            if !viewModel.cartService.items.isEmpty {
                checkoutFooterBar
            }
        }
        .navigationTitle("My Cart")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showGroupCart) {
            GroupCartView()
        }
        .navigationDestination(isPresented: $viewModel.showCheckout) {
            CheckoutView()
        }
    }
    
    private var deliveryBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.badge.checkmark.fill")
                .foregroundColor(BlinkitTheme.brandGreen)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Delivery in 8-10 minutes")
                    .font(.system(size: 14, weight: .bold))
                Text("Shipment of \(viewModel.cartService.totalItemCount) items")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(BlinkitTheme.brandGreenLight)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    private var groupCartBanner: some View {
        Button(action: {
            viewModel.showGroupCart = true
            BlinkitTheme.triggerHaptic(.medium)
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(BlinkitTheme.yellow.opacity(0.3))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.3.sequence.fill")
                        .foregroundColor(BlinkitTheme.textPrimaryLight)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Group Cart")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        Text("SOCIAL")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple)
                            .cornerRadius(4)
                    }
                    Text("Add items live with friends & family")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.fill.badge.minus")
                .font(.system(size: 54))
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 20)
            
            Text("Your cart is empty")
                .font(.system(size: 18, weight: .bold))
            
            Text("Explore categories and add fresh groceries to your cart")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
    
    private var cartItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cart Items")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ForEach(viewModel.cartService.items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .frame(width: 50, height: 50)
                            Image(systemName: item.product.systemImage)
                                .font(.system(size: 24))
                                .foregroundColor(BlinkitTheme.brandGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.product.name)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                            
                            HStack(spacing: 6) {
                                Text(item.product.unit)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                // Added by tag
                                Text("Added by \(item.addedBy.name)")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(hex: item.addedBy.colorHex))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: item.addedBy.colorHex).opacity(0.15))
                                    .cornerRadius(4)
                            }
                            
                            Text("₹\(Int(item.totalCost))")
                                .font(.system(size: 14, weight: .bold))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            QuantityStepperView(
                                quantity: item.quantity,
                                onIncrement: {
                                    withAnimation {
                                        viewModel.updateQuantity(item: item, delta: 1)
                                    }
                                },
                                onDecrement: {
                                    withAnimation {
                                        viewModel.updateQuantity(item: item, delta: -1)
                                    }
                                }
                            )
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    viewModel.deleteItem(item)
                                }
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
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
                    Text("Items Total")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.itemTotal))")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Handling Fee")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.handlingFee))")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Delivery Charge")
                        .foregroundColor(.secondary)
                    Spacer()
                    if viewModel.cartService.deliveryFee == 0 {
                        Text("FREE")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                    } else {
                        Text("₹\(Int(viewModel.cartService.deliveryFee))")
                            .fontWeight(.semibold)
                    }
                }
                
                if viewModel.cartService.totalSavings > 0 {
                    Divider()
                    HStack {
                        Text("Total Savings")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                        Spacer()
                        Text("-₹\(Int(viewModel.cartService.totalSavings))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Grand Total")
                        .font(.system(size: 16, weight: .black))
                    Spacer()
                    Text("₹\(Int(viewModel.cartService.grandTotal))")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(BlinkitTheme.brandGreen)
                }
            }
            .font(.system(size: 13))
            .padding(14)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
    }
    
    private var savedListsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("1-Tap Reorder (Saved Lists)")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("FAST")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(BlinkitTheme.brandGreen)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(BlinkitTheme.brandGreenLight)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.savedLists) { list in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: list.iconName)
                                    .foregroundColor(BlinkitTheme.brandGreen)
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                            }
                            
                            Text(list.title)
                                .font(.system(size: 13, weight: .bold))
                                .lineLimit(1)
                            
                            Text(list.subtitle)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Button(action: {
                                viewModel.addSavedList(list)
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add All Items")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(BlinkitTheme.brandGreen)
                                .cornerRadius(8)
                            }
                        }
                        .padding(12)
                        .frame(width: 170)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var checkoutFooterBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("₹\(Int(viewModel.cartService.grandTotal))")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.primary)
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
                .background(BlinkitTheme.brandGreen)
                .cornerRadius(14)
                .shadow(color: BlinkitTheme.brandGreen.opacity(0.4), radius: 6, x: 0, y: 3)
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
    }
}
