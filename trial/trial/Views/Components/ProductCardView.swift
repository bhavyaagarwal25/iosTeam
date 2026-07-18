//
//  ProductCardView.swift
//  BlinkitFlow
//

import SwiftUI

public struct ProductCardView: View {
    public let product: Product
    public let cartQuantity: Int
    public let onAdd: () -> Void
    public let onIncrement: () -> Void
    public let onDecrement: () -> Void
    
    public init(
        product: Product,
        cartQuantity: Int,
        onAdd: @escaping () -> Void,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.product = product
        self.cartQuantity = cartQuantity
        self.onAdd = onAdd
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Image Container
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(height: 110)
                
                if let uiImage = UIImage(named: "\(product.name.components(separatedBy: " ")[0].lowercased())_product") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(systemName: product.systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(BlinkitTheme.brandGreen)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Top Badge (Tag / Discount)
                if let tag = product.tag {
                    Text(tag)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(BlinkitTheme.brandGreen)
                        .cornerRadius(4)
                        .padding(6)
                } else if let savings = product.savingsPercentage {
                    Text("\(savings)% OFF")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue)
                        .cornerRadius(4)
                        .padding(6)
                }
                
                // Delivery Time Pill
                VStack {
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 8))
                            .foregroundColor(BlinkitTheme.yellow)
                        Text(product.deliveryTime.uppercased())
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(uiColor: .systemBackground).opacity(0.9))
                    .cornerRadius(4)
                    .padding(4)
                }
            }
            
            // Name & Unit
            Text(product.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(height: 34, alignment: .topLeading)
            
            Text(product.unit)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer(minLength: 0)
            
            // Price & Add Button Row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("₹\(Int(product.effectivePrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let original = product.discountPrice, original < product.price {
                        Text("₹\(Int(product.price))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .strikethrough()
                    }
                }
                
                Spacer()
                
                if cartQuantity > 0 {
                    QuantityStepperView(
                        quantity: cartQuantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement
                    )
                } else {
                    Button(action: onAdd) {
                        Text("ADD")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(BlinkitTheme.brandGreen, lineWidth: 1.5)
                                    .background(BlinkitTheme.brandGreenLight.cornerRadius(8))
                            )
                    }
                }
            }
        }
        .padding(10)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .separator).opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
