//
//  ZomatoCartView.swift
//  trial
//

import SwiftUI

public struct ZomatoCartView: View {
    @StateObject private var viewModel = ZomatoCartViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckout = false
    
    public var body: some View {
        VStack(spacing: 0) {
            // Dedicated Top Header Bar with Back & Close buttons
            cartHeaderBar
            
            Divider()
            
            if viewModel.cartService.items.isEmpty {
                emptyCartView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Restaurant header
                        restaurantHeader
                        
                        Divider().padding(.horizontal, 16)
                        
                        // Cart items
                        ForEach(viewModel.cartService.items) { item in
                            cartItemRow(item)
                            Divider().padding(.horizontal, 16)
                        }
                        
                        // Delivery instructions
                        instructionsView
                        
                        Divider().padding(.horizontal, 16)
                        
                        // Coupon
                        couponSection
                        
                        Divider().padding(.horizontal, 16)
                        
                        // Tip
                        tipSection
                        
                        Divider().padding(.horizontal, 16)
                        
                        // Bill
                        billSummary
                        
                        // Donation
                        donationSection
                        
                        Spacer().frame(height: 100)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    checkoutButton
                }
            }
        }
        .fullScreenCover(isPresented: $showCheckout) {
            ZomatoCheckoutView()
        }
    }
    
    // MARK: - Cart Header Bar
    private var cartHeaderBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            Text("Cart")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.white)
    }
    
    // MARK: - Empty Cart
    private var emptyCartView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cart").font(.system(size: 60)).foregroundColor(.gray.opacity(0.3))
            Text("Your cart is empty").font(.system(size: 22, weight: .bold))
            Text("Add items from a restaurant to get started")
                .font(.system(size: 15)).foregroundColor(.secondary)
            Button(action: { dismiss() }) {
                Text("Browse Restaurants").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 28).padding(.vertical, 14).background(Color.red).cornerRadius(10)
            }.padding(.top, 8)
            Spacer()
        }
    }
    
    // MARK: - Restaurant Header
    private var restaurantHeader: some View {
        HStack(spacing: 12) {
            Image(MockZomatoData.restaurants.first(where: { $0.id == viewModel.cartService.currentRestaurantId })?.imageName ?? "pizza")
                .resizable().aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50).cornerRadius(8).clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.cartService.currentRestaurantName ?? "")
                    .font(.system(size: 18, weight: .bold))
                if let r = MockZomatoData.restaurants.first(where: { $0.id == viewModel.cartService.currentRestaurantId }) {
                    Text(r.cuisineText).font(.system(size: 13)).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Cart Item
    private func cartItemRow(_ item: ZomatoCartItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.menuItem.isVeg ? "leaf.circle.fill" : "triangle.fill")
                .foregroundColor(item.menuItem.isVeg ? .green : .red)
                .font(.system(size: 14)).padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.menuItem.name).font(.system(size: 15, weight: .medium))
                
                if !item.customizationSummary.isEmpty {
                    Text(item.customizationSummary)
                        .font(.system(size: 12)).foregroundColor(.secondary)
                }
                
                Text("₹\(Int(item.itemTotal))").font(.system(size: 14, weight: .medium))
            }
            
            Spacer()
            
            // Quantity stepper
            HStack(spacing: 14) {
                Button(action: { viewModel.updateQuantity(item: item, delta: -1) }) {
                    Image(systemName: "minus").font(.system(size: 12, weight: .bold))
                }
                Text("\(item.quantity)").font(.system(size: 15, weight: .heavy))
                Button(action: { viewModel.updateQuantity(item: item, delta: 1) }) {
                    Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                }
            }
            .foregroundColor(.green)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(Color.green.opacity(0.08)).cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
    
    // MARK: - Instructions
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Delivery instructions").font(.system(size: 14, weight: .bold))
            HStack {
                Image(systemName: "text.bubble").foregroundColor(.gray)
                TextField("Any specific instructions for delivery", text: Binding(
                    get: { viewModel.cartService.deliveryInstructions },
                    set: { viewModel.cartService.deliveryInstructions = $0 }
                ))
                    .font(.system(size: 14))
            }
            .padding(10).background(Color.gray.opacity(0.05)).cornerRadius(8)
        }
        .padding(16)
    }
    
    // MARK: - Coupon
    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let coupon = viewModel.cartService.appliedCoupon {
                HStack {
                    Image(systemName: "tag.fill").foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text(coupon.code).font(.system(size: 14, weight: .bold))
                        Text("You saved ₹\(Int(viewModel.cartService.couponDiscount))").font(.system(size: 12)).foregroundColor(.green)
                    }
                    Spacer()
                    Button(action: { viewModel.cartService.removeCoupon() }) {
                        Text("Remove").font(.system(size: 13)).foregroundColor(.red)
                    }
                }
            } else {
                Button(action: { viewModel.showCouponEntry.toggle() }) {
                    HStack {
                        Image(systemName: "percent").foregroundColor(.blue)
                        Text("Apply Coupon").font(.system(size: 15, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray)
                    }.foregroundColor(.primary)
                }
                
                if viewModel.showCouponEntry {
                    VStack(spacing: 8) {
                        HStack {
                            TextField("Enter coupon code", text: $viewModel.couponCode)
                                .textInputAutocapitalization(.characters).font(.system(size: 15))
                                .padding(10).background(Color.gray.opacity(0.05)).cornerRadius(8)
                            
                            Button(action: { viewModel.applyCoupon() }) {
                                Text("Apply").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(Color.red).cornerRadius(8)
                            }
                        }
                        
                        if let error = viewModel.couponError {
                            Text(error).font(.system(size: 12)).foregroundColor(.red)
                        }
                        
                        // Suggested coupons
                        if !viewModel.availableCoupons.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Coupons").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                                ForEach(viewModel.availableCoupons.prefix(3)) { coupon in
                                    Button(action: {
                                        viewModel.couponCode = coupon.code
                                        viewModel.applyCoupon()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(coupon.code).font(.system(size: 13, weight: .bold))
                                                Text(coupon.description).font(.system(size: 11)).foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("Save ₹\(Int(coupon.discountFor(orderTotal: viewModel.cartService.itemTotal)))")
                                                .font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                                        }
                                        .padding(10).background(Color.green.opacity(0.05)).cornerRadius(8)
                                    }.foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Tip
    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tip your rider").font(.system(size: 14, weight: .bold))
                Spacer()
                Text("100% goes to rider").font(.system(size: 11)).foregroundColor(.secondary)
            }
            
            HStack(spacing: 10) {
                ForEach(viewModel.tipOptions, id: \.self) { tip in
                    Button(action: { viewModel.selectTip(tip) }) {
                        Text("₹\(Int(tip))")
                            .font(.system(size: 14, weight: viewModel.cartService.tipAmount == tip ? .bold : .medium))
                            .foregroundColor(viewModel.cartService.tipAmount == tip ? .white : .primary)
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(viewModel.cartService.tipAmount == tip ? Color.green : Color.gray.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Bill Summary
    private var billSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bill Details").font(.system(size: 16, weight: .bold)).padding(.bottom, 4)
            
            billRow("Item Total", "₹\(Int(viewModel.cartService.itemTotal))")
            billRow("Delivery Fee", viewModel.cartService.isDeliveryFree ? "FREE" : "₹\(Int(viewModel.cartService.deliveryFee))", valueColor: viewModel.cartService.isDeliveryFree ? .green : nil)
            billRow("GST (5%)", "₹\(Int(viewModel.cartService.taxes))")
            billRow("Packaging Fee", "₹\(Int(viewModel.cartService.packagingFee))")
            billRow("Platform Fee", "₹\(Int(viewModel.cartService.platformFee))")
            
            if viewModel.cartService.tipAmount > 0 {
                billRow("Tip", "₹\(Int(viewModel.cartService.tipAmount))")
            }
            if viewModel.cartService.donationAmount > 0 {
                billRow("Donation", "₹\(Int(viewModel.cartService.donationAmount))")
            }
            if viewModel.cartService.couponDiscount > 0 {
                billRow("Coupon Discount", "-₹\(Int(viewModel.cartService.couponDiscount))", valueColor: .green)
            }
            
            Divider()
            
            HStack {
                Text("Grand Total").font(.system(size: 16, weight: .heavy))
                Spacer()
                Text("₹\(Int(viewModel.cartService.grandTotal))").font(.system(size: 16, weight: .heavy))
            }
        }
        .padding(16)
    }
    
    private func billRow(_ label: String, _ value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(valueColor ?? .primary)
        }
    }
    
    // MARK: - Donation
    private var donationSection: some View {
        Button(action: { viewModel.cartService.toggleDonation() }) {
            HStack {
                Image(systemName: viewModel.cartService.donationAmount > 0 ? "checkmark.square.fill" : "square")
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Feeding India Donation").font(.system(size: 14, weight: .medium))
                    Text("Donate ₹1 to help feed the needy").font(.system(size: 12)).foregroundColor(.secondary)
                }
                Spacer()
                Text("₹1").font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.primary).padding(16)
        }
    }
    
    // MARK: - Checkout Button
    private var checkoutButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: { showCheckout = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("₹\(Int(viewModel.cartService.grandTotal))")
                            .font(.system(size: 16, weight: .heavy))
                        Text("TOTAL")
                            .font(.system(size: 10, weight: .medium))
                            .opacity(0.9)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Text("Proceed to Checkout")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(red: 0.9, green: 0.1, blue: 0.2))
                .cornerRadius(14)
                .shadow(color: Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }
}
