//
//  CheckoutView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct CheckoutView: View {
    @StateObject private var viewModel: CheckoutViewModel
    public var onOrderPlaced: (() -> Void)? = nil
    
    public init(onOrderPlaced: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel())
        self.onOrderPlaced = onOrderPlaced
    }
    
    public init(viewModel: CheckoutViewModel, onOrderPlaced: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOrderPlaced = onOrderPlaced
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Delivery Location Card
                    addressCard
                    
                    // Delivery Speed Card
                    deliverySpeedCard
                    
                    // Payment Method Options
                    paymentOptionsCard
                    
                    // Order Summary
                    orderSummaryCard
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top, 12)
            }
            
            // Bottom Place Order Bar
            placeOrderBar
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false) // Fix for broken back button when pushed from CartView
        .navigationBarHidden(false)
    }
    
    private var addressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(BlinkitTheme.brandGreen)
                    .font(.system(size: 20))
                Text("Delivery Location")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Button("Change") {
                    BlinkitTheme.triggerHaptic(.light)
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BlinkitTheme.brandGreen)
            }
            
            Text("Home")
                .font(.system(size: 13, weight: .bold))
            Text(viewModel.selectedAddress)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    private var deliverySpeedCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(BlinkitTheme.yellow.opacity(0.3))
                    .frame(width: 44, height: 44)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 22))
                    .foregroundColor(BlinkitTheme.textPrimaryLight)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Superfast 10 MINS Delivery")
                    .font(.system(size: 15, weight: .bold))
                Text("Your store rider will be assigned instantly")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(BlinkitTheme.yellow.opacity(0.15))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(BlinkitTheme.yellow.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    private var paymentOptionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Payment Method")
                .font(.system(size: 15, weight: .bold))
            
            VStack(spacing: 8) {
                ForEach(viewModel.paymentOptions, id: \.self) { option in
                    Button(action: {
                        viewModel.selectedPaymentMethod = option
                        BlinkitTheme.triggerHaptic(.light)
                    }) {
                        HStack {
                            Image(systemName: viewModel.selectedPaymentMethod == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedPaymentMethod == option ? BlinkitTheme.brandGreen : .secondary)
                                .font(.system(size: 18))
                            
                            Text(option)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if option.contains("UPI") {
                                Text("RECOMMENDED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(BlinkitTheme.brandGreen)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(BlinkitTheme.brandGreenLight)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(12)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.selectedPaymentMethod == option ? BlinkitTheme.brandGreen : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    private var orderSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order Items (\(viewModel.cartService.items.count))")
                .font(.system(size: 15, weight: .bold))
            
            ForEach(viewModel.cartService.items) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                        .font(.system(size: 13))
                        .lineLimit(1)
                    Spacer()
                    Text("₹\(Int(item.totalCost))")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            
            Divider().padding(.vertical, 4)
            
            HStack {
                Text("Total Payable")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Text("₹\(Int(viewModel.cartService.grandTotal))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BlinkitTheme.brandGreen)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    private var placeOrderBar: some View {
        Button(action: {
            // DEMO: Live Activity starts here
            viewModel.placeOrder()
            onOrderPlaced?()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("PAY ₹\(Int(viewModel.cartService.grandTotal))")
                        .font(.system(size: 16, weight: .black))
                    Text(viewModel.selectedPaymentMethod)
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.8)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("Place Order")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(BlinkitTheme.brandGreen)
            .cornerRadius(16)
            .shadow(color: BlinkitTheme.brandGreen.opacity(0.4), radius: 8, x: 0, y: 4)
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
        }
    }
}
