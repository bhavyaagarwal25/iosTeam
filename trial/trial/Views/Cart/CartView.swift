//
//  CartView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct CartView: View {
    @Environment(\.dismiss) private var dismiss
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
                Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    customNavBar
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            
                            // Delivery ETA banner
                            deliveryBanner
                                .padding(.top, 12)
                            
                            if viewModel.cartService.items.isEmpty {
                                emptyCartView
                            } else {
                                // Cart Items List
                                cartItemsSection
                                
                                // You might also like
                                youMightAlsoLikeSection
                                
                                // Bill Details Breakdown
                                billDetailsSection
                            }
                            
                            Spacer().frame(height: 120)
                        }
                    }
                }
                
                // Bottom Checkout Footer
                if !viewModel.cartService.items.isEmpty {
                    checkoutFooterBar
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.showGroupCart) {
                GroupCartView()
            }
            .navigationDestination(isPresented: $viewModel.showCheckout) {
                CheckoutView(onOrderPlaced: {
                    viewModel.showCheckout = false
                    NotificationCenter.default.post(name: NSNotification.Name("SwitchToTrackingTab"), object: nil)
                })
            }
        }
    }
    
    private var customNavBar: some View {
        HStack {
            Button(action: {
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToHomeTab"), object: nil)
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            Text("Cart")
                .font(.system(size: 18, weight: .bold))
                .padding(.leading, 8)
            
            Spacer()
            
            HStack(spacing: 12) {
                if !viewModel.cartService.items.isEmpty {
                    Button(action: {
                        viewModel.cartService.clearCart()
                        BlinkitTheme.triggerHaptic(.medium)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                }
            }
        }.padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var deliveryBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "clock.fill")
                    .foregroundColor(BlinkitTheme.brandGreen)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Delivery in 11 minutes")
                    .font(.system(size: 16, weight: .bold))
                Text("Shipment of \(viewModel.cartService.totalItemCount) items")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
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
        VStack(spacing: 0) {
            ForEach(Array(viewModel.cartService.items.enumerated()), id: \.element.id) { index, item in
                HStack(alignment: .top, spacing: 16) {
                    // Image
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(width: 70, height: 70)
                        
                        if let uiImage = UIImage(named: "\(item.product.name.components(separatedBy: " ")[0].lowercased())_product") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        } else {
                            Image(systemName: item.product.systemImage)
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.product.name.capitalized)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(item.product.unit)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        // Move to wishlist
                        Button(action: {}) {
                            Text("Move to wishlist")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .underline(true, color: .secondary)
                        }
                        
                        if item.addedBy.id != MockData.currentUser.id {
                            Text("Added by \(item.addedBy.name)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: item.addedBy.colorHex))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: item.addedBy.colorHex).opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        // Stepper
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    viewModel.updateQuantity(item: item, delta: -1)
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            
                            Text("\(item.quantity)")
                                .font(.system(size: 14, weight: .bold))
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.updateQuantity(item: item, delta: 1)
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(BlinkitTheme.brandGreen)
                        .cornerRadius(8)
                        
                        // Price
                        Text("₹\(Int(item.totalCost))")
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .padding(16)
                
                if index < viewModel.cartService.items.count - 1 {
                    Divider()
                        .padding(.leading, 102)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var youMightAlsoLikeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You might also like")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MockData.sampleProducts.shuffled().prefix(4)) { product in
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                                    .frame(width: 130, height: 130)
                                
                                if let uiImage = UIImage(named: "\(product.name.components(separatedBy: " ")[0].lowercased())_product") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .padding(15)
                                } else {
                                    Image(systemName: product.systemImage)
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                        .frame(width: 130, height: 130)
                                }
                                
                                Image(systemName: "heart")
                                    .foregroundColor(.gray)
                                    .padding(8)
                            }
                            
                            HStack {
                                Text(product.unit)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: {
                                    viewModel.cartService.addToCart(product: product)
                                }) {
                                    Text("ADD")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(BlinkitTheme.brandGreen)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(BlinkitTheme.brandGreen, lineWidth: 1)
                                        )
                                }
                            }
                            
                            Text("₹\(Int(product.price))")
                                .font(.system(size: 14, weight: .bold))
                            
                            Text(product.name.capitalized)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(2)
                                .frame(height: 32, alignment: .topLeading)
                        }
                        .frame(width: 130)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
            }
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
            .background(Color.white)
            .cornerRadius(14)
        }
        .padding(.horizontal, 16)
    }
    
    private var checkoutFooterBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Button(action: {
                    viewModel.showCheckout = true
                    BlinkitTheme.triggerHaptic(.medium)
                }) {
                    HStack {
                        Text("Pay")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 45/255, green: 115/255, blue: 37/255)) // Darker Green from screenshot
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 34) // safe area spacing
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
        }
    }
}
