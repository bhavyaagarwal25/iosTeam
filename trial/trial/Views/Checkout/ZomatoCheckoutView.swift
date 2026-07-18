//
//  ZomatoCheckoutView.swift
//  trial
//
//  Premium Zomato Checkout View with grouped card aesthetic, rich typography, and Zomato Red theme.
//

import SwiftUI

public struct ZomatoCheckoutView: View {
    @StateObject private var viewModel = ZomatoCheckoutViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showOrderSuccess = false
    @State private var navigateToTracking = false
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Grouped System Background (#F8F9FA / grouped background)
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header Bar
                topHeaderBar
                
                if showOrderSuccess, let order = viewModel.placedOrder {
                    orderSuccessView(order)
                } else {
                    checkoutScrollView
                }
            }
            
            // Payment Processing Overlay
            if viewModel.showPaymentProcessing {
                paymentProcessingOverlay
            }
        }
        .onChange(of: viewModel.placedOrder) { _, newOrder in
            if newOrder != nil {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showOrderSuccess = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToTracking) {
            ZomatoOrderTrackingView()
        }
    }
    
    // MARK: - Top Header Bar
    private var topHeaderBar: some View {
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
            
            Text("Checkout")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Scrollable Checkout Content (Card Grouped Layout)
    private var checkoutScrollView: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Delivery Address Card
                    addressCardSection
                    
                    // Delivery Time Card
                    deliveryTimeCardSection
                    
                    // Zomato Gold Savings Banner
                    goldSavingsBannerCard
                    
                    // Select Payment Method Card
                    paymentMethodCardSection
                    
                    // Order Summary Card
                    orderSummaryCardSection
                    
                    // Bill Summary Card
                    billSummaryCardSection
                    
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            
            // Bottom Fixed Place Order Bar
            bottomPlaceOrderBar
        }
    }
    
    // MARK: - Address Card Section
    private var addressCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DELIVER TO")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                ForEach(viewModel.addresses) { address in
                    Button(action: {
                        viewModel.selectedAddress = address
                        BlinkitTheme.triggerHaptic(.light)
                    }) {
                        HStack(spacing: 12) {
                            // Red Selection Radio Ring
                            ZStack {
                                Circle()
                                    .stroke(viewModel.selectedAddress.id == address.id ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.35), lineWidth: 1.5)
                                    .frame(width: 20, height: 20)
                                
                                if viewModel.selectedAddress.id == address.id {
                                    Circle()
                                        .fill(Color(red: 0.9, green: 0.1, blue: 0.2))
                                        .frame(width: 12, height: 12)
                                }
                            }
                            
                            // Address Type Icon
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.08))
                                    .frame(width: 34, height: 34)
                                Image(systemName: address.iconName)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(address.label)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    if address.isDefault {
                                        Text("DEFAULT")
                                            .font(.system(size: 9, weight: .heavy))
                                            .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(red: 1.0, green: 0.93, blue: 0.94))
                                            .cornerRadius(4)
                                    }
                                }
                                
                                Text(address.fullAddress)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(viewModel.selectedAddress.id == address.id ? Color(red: 1.0, green: 0.96, blue: 0.97) : Color.gray.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.selectedAddress.id == address.id ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.clear, lineWidth: 1.2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Delivery Time Card Section
    private var deliveryTimeCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DELIVERY TIME")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                // Now Option
                Button(action: {
                    viewModel.isScheduled = false
                    BlinkitTheme.triggerHaptic(.light)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Now")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            Text("25-35 mins")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(!viewModel.isScheduled ? Color(red: 1.0, green: 0.95, blue: 0.96) : Color.gray.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(!viewModel.isScheduled ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.2), lineWidth: 1.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Schedule Option
                Button(action: {
                    viewModel.isScheduled = true
                    BlinkitTheme.triggerHaptic(.light)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.isScheduled ? Color(red: 0.9, green: 0.1, blue: 0.2) : .gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Schedule")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Pick a time")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(viewModel.isScheduled ? Color(red: 1.0, green: 0.95, blue: 0.96) : Color.gray.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.isScheduled ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.2), lineWidth: 1.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if viewModel.isScheduled {
                DatePicker("", selection: $viewModel.scheduledDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden().datePickerStyle(.compact)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Zomato Gold Savings Banner Card
    private var goldSavingsBannerCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Zomato Gold Savings Applied")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                Text("₹30 Free Delivery + 10% Gold extra discount")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(red: 1.0, green: 0.95, blue: 0.96))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Payment Method Card Section
    private var paymentMethodCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SELECT PAYMENT METHOD")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.secondary)
            
            ForEach(ZomatoPaymentCategory.allCases) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    let options = viewModel.paymentOptions.filter { $0.category == category }
                    ForEach(options) { option in
                        Button(action: {
                            viewModel.selectedPaymentOption = option
                            BlinkitTheme.triggerHaptic(.light)
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .stroke(viewModel.selectedPaymentOption.id == option.id ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.35), lineWidth: 1.5)
                                        .frame(width: 20, height: 20)
                                    
                                    if viewModel.selectedPaymentOption.id == option.id {
                                        Circle()
                                            .fill(Color(red: 0.9, green: 0.1, blue: 0.2))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                
                                Image(systemName: option.iconName)
                                    .font(.system(size: 18))
                                    .foregroundColor(viewModel.selectedPaymentOption.id == option.id ? Color(red: 0.9, green: 0.1, blue: 0.2) : .primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(option.name)
                                            .font(.system(size: 14, weight: viewModel.selectedPaymentOption.id == option.id ? .bold : .medium))
                                            .foregroundColor(.primary)
                                        
                                        if let badge = option.badgeText {
                                            Text(badge)
                                                .font(.system(size: 9, weight: .heavy))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color(red: 0.9, green: 0.1, blue: 0.2))
                                                .cornerRadius(4)
                                        }
                                    }
                                    
                                    if let offer = option.offerText {
                                        Text(offer)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(viewModel.selectedPaymentOption.id == option.id ? Color(red: 1.0, green: 0.95, blue: 0.96) : Color.gray.opacity(0.03))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.selectedPaymentOption.id == option.id ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.1), lineWidth: 1.2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Order Summary Card Section
    private var orderSummaryCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ORDER SUMMARY")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.cartService.totalItemCount) items")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            ForEach(viewModel.cartService.items) { item in
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(item.menuItem.isVeg ? Color.green : Color.red, lineWidth: 1.5)
                            .frame(width: 13, height: 13)
                        
                        if item.menuItem.isVeg {
                            Circle().fill(Color.green).frame(width: 5, height: 5)
                        } else {
                            Image(systemName: "triangle.fill").font(.system(size: 5)).foregroundColor(.red)
                        }
                    }
                    
                    Text(item.menuItem.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("×\(item.quantity)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("₹\(Int(item.itemTotal))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Bill Summary Card Section
    private var billSummaryCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BILL DETAILS")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.secondary)
            
            billRow("Item Total", "₹\(Int(viewModel.cartService.itemTotal))")
            billRow("Delivery Fee", viewModel.cartService.isDeliveryFree ? "FREE" : "₹\(Int(viewModel.cartService.deliveryFee))", isGreenText: viewModel.cartService.isDeliveryFree)
            billRow("Taxes & Charges", "₹\(Int(viewModel.cartService.taxes + viewModel.cartService.packagingFee + viewModel.cartService.platformFee))")
            
            if viewModel.cartService.couponDiscount > 0 {
                billRow("Coupon Discount", "-₹\(Int(viewModel.cartService.couponDiscount))", isGreenText: true)
            }
            
            Divider()
            
            HStack {
                Text("Grand Total")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.primary)
                Spacer()
                Text("₹\(Int(viewModel.cartService.grandTotal))")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    private func billRow(_ label: String, _ value: String, isGreenText: Bool = false) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isGreenText ? Color(red: 0.1, green: 0.55, blue: 0.3) : .primary)
        }
    }
    
    // MARK: - Bottom Fixed Place Order Bar
    private var bottomPlaceOrderBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: { viewModel.placeOrder() }) {
                HStack(spacing: 8) {
                    if viewModel.isPlacingOrder {
                        ProgressView().tint(.white)
                        Text("Connecting...")
                            .font(.system(size: 15, weight: .bold))
                    } else {
                        Text("Pay via \(viewModel.selectedPaymentOption.name) • ₹\(Int(viewModel.cartService.grandTotal))")
                            .font(.system(size: 16, weight: .heavy))
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .background(Color(red: 0.9, green: 0.1, blue: 0.2))
                .cornerRadius(14)
                .shadow(color: Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .disabled(viewModel.isPlacingOrder)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }
    
    // MARK: - Payment Processing Overlay
    private var paymentProcessingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.4)
                    .tint(Color(red: 0.9, green: 0.1, blue: 0.2))
                
                VStack(spacing: 6) {
                    Text("Redirecting to \(viewModel.selectedPaymentOption.name)...")
                        .font(.system(size: 16, weight: .bold))
                    Text("Please do not press back or close the app")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(28)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 12)
            .padding(30)
        }
    }
    
    // MARK: - Success View
    private func orderSuccessView(_ order: ZomatoOrder) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle().fill(Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.1)).frame(width: 120, height: 120)
                Circle().fill(Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.2)).frame(width: 90, height: 90)
                Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
            }
            .scaleEffect(showOrderSuccess ? 1 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showOrderSuccess)
            
            VStack(spacing: 8) {
                Text("Order Placed! 🎉").font(.system(size: 26, weight: .heavy))
                Text("Order #\(order.id)").font(.system(size: 15)).foregroundColor(.secondary)
                Text(order.restaurantName).font(.system(size: 16, weight: .medium))
            }
            
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill").foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                    Text("Estimated delivery: \(order.estimatedMinutes) mins").font(.system(size: 15, weight: .medium))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill").foregroundColor(.red)
                    Text(order.deliveryAddress).font(.system(size: 13)).foregroundColor(.secondary).lineLimit(1)
                }
            }
            
            Button(action: { navigateToTracking = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                    Text("Track Live Order")
                }
                .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Color(red: 0.9, green: 0.1, blue: 0.2))
                .cornerRadius(14)
                .shadow(color: Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.3), radius: 8, x: 0, y: 4)
            }.padding(.horizontal, 32)
            
            Spacer()
        }
        .padding()
    }
}
