//
//  CategoryView.swift
//  BlinkitFlow
//
//  Pixel-accurate rebuild from Figma node 1:137
//

import SwiftUI

@MainActor
public struct CategoryView: View {
    public init() {}

    // Figma: 5 tiles per row, each 71×78pt, 5 px gap = 80pt step
    private let tileSize: CGFloat = 71
    private let tilePadding: CGFloat = 8

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // ── Shared Header ──
                categoryHeader

                // ── Section 1: Grocery & Kitchen (Figma y:185) ──
                categorySectionView(
                    title: "Grocery & Kitchen",
                    rows: [
                        [
                            ("Vegetables\n& Fruits", "carrot.fill", Color(red: 0.85, green: 1, blue: 0.85)),
                            ("Atta, Dal\n& Rice", "takeoutbox.fill", Color(red: 1, green: 0.95, blue: 0.8)),
                            ("Oil, Ghee\n& Masala", "drop.fill", Color(red: 1, green: 0.9, blue: 0.75)),
                            ("Dairy, Bread\n& Milk", "cup.and.saucer.fill", Color(red: 0.85, green: 0.93, blue: 1)),
                            ("Biscuits\n& Bakery", "birthday.cake.fill", Color(red: 1, green: 0.9, blue: 0.9))
                        ],
                        [
                            ("Dry Fruits\n& Cereals", "leaf.fill", Color(red: 0.95, green: 0.88, blue: 1)),
                            ("Kitchen &\nAppliances", "tv.fill", Color(red: 0.85, green: 0.92, blue: 1)),
                            ("Tea &\nCoffees", "cup.and.saucer.fill", Color(red: 1, green: 0.92, blue: 0.8)),
                            ("Ice Creams\n& much more", "snowflake", Color(red: 0.85, green: 0.95, blue: 1)),
                            ("Noodles &\nPacket Food", "fork.knife", Color(red: 1, green: 0.95, blue: 0.85))
                        ]
                    ]
                )

                // ── Section 2: Snacks & Drinks (Figma y:472) ──
                categorySectionView(
                    title: "Snacks & Drinks",
                    rows: [
                        [
                            ("Chips &\nNamkeens", "takeoutbox.fill", Color(red: 1, green: 0.9, blue: 0.7)),
                            ("Sweets &\nChocolates", "gift.fill", Color(red: 1, green: 0.85, blue: 0.9)),
                            ("Drinks &\nJuices", "wineglass.fill", Color(red: 0.85, green: 0.95, blue: 1)),
                            ("Sauces &\nSpreads", "drop.fill", Color(red: 1, green: 0.88, blue: 0.8)),
                            ("Beauty &\nCosmetics", "sparkles", Color(red: 1, green: 0.9, blue: 0.95))
                        ]
                    ]
                )

                // ── Section 3: Household Essentials (Figma y:632) ──
                categorySectionView(
                    title: "Household Essentials",
                    rows: [
                        [
                            ("Cleaning\nEssentials", "bubbles.and.sparkles.fill", Color(red: 0.85, green: 0.95, blue: 1)),
                            ("Laundry\n& Detergent", "washer.fill", Color(red: 0.9, green: 0.88, blue: 1)),
                            ("Personal\nCare", "person.fill", Color(red: 1, green: 0.92, blue: 0.88)),
                            ("Baby\nCare", "figure.2.and.child.holdinghands", Color(red: 0.88, green: 1, blue: 0.9)),
                            ("Pet\nSupplies", "pawprint.fill", Color(red: 1, green: 0.95, blue: 0.8))
                        ]
                    ]
                )

                Spacer().frame(height: 90)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }

    // MARK: – Shared Header (same structure as Figma)
    private var categoryHeader: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Color(red: 0.1, green: 0.57, blue: 0.25)
                    .frame(height: 110)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Blinkit in")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 52)
                        .padding(.leading, 16)

                    HStack(spacing: 4) {
                        Text("16 minutes")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 2)

                    HStack(spacing: 4) {
                        Text("HOME")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("- Sujal Dave, Ratanada, Jodhpur (Raj)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.leading, 16)
                    .padding(.top, 4)
                }

                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 55)
                }
            }
            .frame(height: 110)

            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray).font(.system(size: 15))
                Text("Search \"ice-cream\"")
                    .foregroundColor(Color(.placeholderText)).font(.system(size: 14))
                Spacer()
                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 20)
                Image(systemName: "mic.fill")
                    .foregroundColor(.gray).font(.system(size: 15))
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, -4)
            .padding(.bottom, 12)
            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
        }
    }

    // MARK: – Category Section
    private func categorySectionView(title: String, rows: [[(String, String, Color)]]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header — Figma: e.g., "Grocery & Kitchen" x:15, y:185, h:21
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal, 15)
                .padding(.top, 16)
                .padding(.bottom, 10)

            // Each row of 5 tiles
            ForEach(rows.indices, id: \.self) { rowIdx in
                HStack(spacing: 0) {
                    ForEach(rows[rowIdx].indices, id: \.self) { colIdx in
                        let item = rows[rowIdx][colIdx]
                        categoryTile(label: item.0, icon: item.1, bgColor: item.2)
                    }
                }
                .padding(.bottom, 4)
            }

            // Divider between sections
            Divider()
                .padding(.top, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: – Individual Category Tile (Figma: 71×78pt)
    private func categoryTile(label: String, icon: String, bgColor: Color) -> some View {
        VStack(spacing: 0) {
            // Tile rectangle — Figma: 71×78pt
            ZStack {
                bgColor
                VStack {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(.primary.opacity(0.7))
                }
            }
            .frame(width: 71, height: 54)
            .cornerRadius(0)

            // Label below tile
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.primary)
                .frame(width: 71, height: 30)
                .padding(.horizontal, 2)
        }
        .frame(width: 71, height: 84)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    CategoryView()
}
