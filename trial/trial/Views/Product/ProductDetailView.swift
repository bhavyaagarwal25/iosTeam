//
//  ProductDetailView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct ProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProductDetailViewModel
    
    public init(product: Product) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Large Image Preview Container
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(height: 240)
                        
                        Image(systemName: viewModel.product.systemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(BlinkitTheme.brandGreen)
                    }
                    .padding(.horizontal, 16)
                    
                    // Product Details Box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            // Delivery Badge
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(BlinkitTheme.yellow)
                                Text(viewModel.product.deliveryTime.uppercased())
                                    .font(.system(size: 10, weight: .black))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(BlinkitTheme.yellow.opacity(0.2))
                            .cornerRadius(6)
                            
                            Spacer()
                            
                            // Rating Badge
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.orange)
                                Text(String(format: "%.1f", viewModel.product.rating))
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(6)
                        }
                        
                        Text(viewModel.product.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(viewModel.product.unit)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("₹\(Int(viewModel.product.effectivePrice))")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(BlinkitTheme.brandGreen)
                            
                            if let orig = viewModel.product.discountPrice, orig < viewModel.product.price {
                                Text("MRP ₹\(Int(viewModel.product.price))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .strikethrough()
                            }
                            
                            if let savings = viewModel.product.savingsPercentage {
                                Text("\(savings)% OFF")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("Product Overview")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text(viewModel.product.description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Bottom Sticky Toolbar
            HStack(spacing: 16) {
                // Quantity Selector
                HStack(spacing: 12) {
                    Button(action: viewModel.decrementQuantity) {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(viewModel.selectedQuantity)")
                        .font(.system(size: 16, weight: .bold))
                    
                    Button(action: viewModel.incrementQuantity) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                    }
                }
                .padding(6)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
                // Add to Cart Button
                Button(action: {
                    viewModel.addToCart()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("Add to Cart • ₹\(Int(viewModel.product.effectivePrice * Double(viewModel.selectedQuantity)))")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BlinkitTheme.brandGreen)
                    .cornerRadius(14)
                    .shadow(color: BlinkitTheme.brandGreen.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        }
    }
}
