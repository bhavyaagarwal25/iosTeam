//
//  CategoryView.swift
//  BlinkitFlow
//
//  Premium iOS Native UI Rebuild
//

import SwiftUI

@MainActor
public struct CategoryView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Section 1
                        categorySectionView(
                            title: "Grocery & Kitchen",
                            rows: [
                                [
                                    ("Vegetables\n& Fruits", "leaf.fill", .green),
                                    ("Atta, Dal\n& Rice", "takeoutbox.fill", .brown),
                                    ("Oil, Ghee\n& Masala", "drop.fill", .yellow),
                                    ("Dairy, Bread\n& Milk", "cup.and.saucer.fill", .blue)
                                ],
                                [
                                    ("Biscuits\n& Bakery", "birthday.cake.fill", .pink),
                                    ("Dry Fruits\n& Cereals", "leaf.arrow.triangle.circlepath", .orange),
                                    ("Kitchen\nAppliances", "tv.fill", .gray),
                                    ("Tea &\nCoffees", "cup.and.saucer.fill", .brown)
                                ]
                            ]
                        )

                        // Section 2
                        categorySectionView(
                            title: "Snacks & Drinks",
                            rows: [
                                [
                                    ("Chips &\nNamkeens", "takeoutbox.fill", .orange),
                                    ("Sweets &\nChocolates", "gift.fill", .purple),
                                    ("Drinks &\nJuices", "wineglass.fill", .red),
                                    ("Sauces &\nSpreads", "drop.fill", .red)
                                ]
                            ]
                        )

                        // Section 3
                        categorySectionView(
                            title: "Household Essentials",
                            rows: [
                                [
                                    ("Cleaning\nEssentials", "bubbles.and.sparkles.fill", .blue),
                                    ("Laundry\n& Detergent", "washer.fill", .cyan),
                                    ("Personal\nCare", "person.fill", .teal),
                                    ("Baby\nCare", "figure.2.and.child.holdinghands", .indigo)
                                ]
                            ]
                        )

                        Spacer().frame(height: 90)
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: – Shared Header
    private var categoryHeader: some View {
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

    // MARK: – Category Section
    private func categorySectionView(title: String, rows: [[(String, String, Color)]]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 16)

            VStack(spacing: 16) {
                ForEach(rows.indices, id: \.self) { rowIdx in
                    HStack(spacing: 16) {
                        ForEach(rows[rowIdx].indices, id: \.self) { colIdx in
                            let item = rows[rowIdx][colIdx]
                            categoryTile(label: item.0, icon: item.1, color: item.2)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .padding(.top, 8)
    }

    private func categoryTile(label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.15))
                    .frame(height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }
}
