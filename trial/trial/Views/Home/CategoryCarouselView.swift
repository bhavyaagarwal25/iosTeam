//
//  CategoryCarouselView.swift
//  BlinkitFlow
//

import SwiftUI

public struct CategoryCarouselView: View {
    @Binding public var selectedCategory: ProductCategory
    public let onSelectCategory: (ProductCategory) -> Void
    
    public init(
        selectedCategory: Binding<ProductCategory>,
        onSelectCategory: @escaping (ProductCategory) -> Void
    ) {
        self._selectedCategory = selectedCategory
        self.onSelectCategory = onSelectCategory
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ProductCategory.allCases) { cat in
                    let isSelected = selectedCategory == cat
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = cat
                            onSelectCategory(cat)
                        }
                        BlinkitTheme.triggerHaptic(.light)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 13, weight: .bold))
                            Text(cat.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ? BlinkitTheme.brandGreen : Color(uiColor: .secondarySystemBackground)
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                        .cornerRadius(20)
                        .shadow(color: isSelected ? BlinkitTheme.brandGreen.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
