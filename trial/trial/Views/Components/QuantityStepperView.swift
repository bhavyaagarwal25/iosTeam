//
//  QuantityStepperView.swift
//  BlinkitFlow
//

import SwiftUI

public struct QuantityStepperView: View {
    public let quantity: Int
    public let onIncrement: () -> Void
    public let onDecrement: () -> Void
    
    public init(
        quantity: Int,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.quantity = quantity
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Button(action: onDecrement) {
                Image(systemName: quantity == 1 ? "trash.fill" : "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
            }
            
            Text("\(quantity)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(minWidth: 16, alignment: .center)
            
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(BlinkitTheme.brandGreen)
        .cornerRadius(8)
        .shadow(color: BlinkitTheme.brandGreen.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
