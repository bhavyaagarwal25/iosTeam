//
//  ZomatoProfileView.swift
//  trial
//

import SwiftUI

public struct ZomatoProfileView: View {
    @StateObject private var viewModel = ZomatoProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Top Space for back button
                        Spacer().frame(height: 44)
                        
                        // User Profile & Gold Card
                        userGoldCard
                        
                        // Action Cards Row (Zomato Money & Your Coupons)
                        actionCardsRow
                        
                        // Your Preferences Section
                        preferencesSection
                        
                        // Food Delivery Section
                        foodDeliverySection
                        
                        Spacer().frame(height: 60)
                    }
                }
                
                // Top Custom Back Bar
                topNavigationBar
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - User & Gold Card
    private var userGoldCard: some View {
        VStack(spacing: 0) {
            // Upper Profile Section
            HStack(alignment: .center, spacing: 16) {
                // Avatar Circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.82, green: 0.89, blue: 0.99))
                        .frame(width: 76, height: 76)
                    Text("S")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.18, green: 0.42, blue: 0.85))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("shubh")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("Edit profile")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Image(systemName: "play.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.white)
            
            // Lower Gold Banner
            Button(action: {}) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.28, green: 0.23, blue: 0.14))
                            .frame(width: 34, height: 34)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.96, green: 0.82, blue: 0.52))
                    }
                    
                    Text("Renew your Gold Membership")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.96, green: 0.85, blue: 0.62))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.96, green: 0.85, blue: 0.62))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Action Cards Row
    private var actionCardsRow: some View {
        HStack(spacing: 12) {
            // Zomato Money Card
            Button(action: {}) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.08))
                            .frame(width: 38, height: 38)
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zomato Money")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text("₹0")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.65, blue: 0.35))
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Your Coupons Card
            Button(action: {}) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.08))
                            .frame(width: 38, height: 38)
                        Image(systemName: "percent")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Text("Your coupons")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Your Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Red Indicator
            HStack(spacing: 8) {
                Capsule()
                    .fill(Color(red: 0.9, green: 0.1, blue: 0.2))
                    .frame(width: 3.5, height: 18)
                Text("Your preferences")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            
            // Card Content
            VStack(spacing: 0) {
                // Veg Mode
                preferenceRow(
                    customIcon: vegIcon,
                    title: "Veg Mode",
                    trailingText: viewModel.vegModeEnabled ? "On" : "Off",
                    hasChevron: true,
                    action: { viewModel.vegModeEnabled.toggle() }
                )
                
                Divider().padding(.leading, 52)
                
                // Show personalised ratings
                HStack(spacing: 16) {
                    Image(systemName: "star")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                    
                    Text("Show personalised ratings")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.showPersonalisedRatings)
                        .labelsHidden()
                        .tint(Color(red: 0.9, green: 0.1, blue: 0.2))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                Divider().padding(.leading, 52)
                
                // Appearance
                preferenceRow(
                    iconName: "paintpalette",
                    title: "Appearance",
                    trailingText: viewModel.darkModeEnabled ? "Dark" : "Light",
                    hasChevron: true,
                    action: { viewModel.darkModeEnabled.toggle() }
                )
                
                Divider().padding(.leading, 52)
                
                // Payment methods
                preferenceRow(
                    iconName: "creditcard",
                    title: "Payment methods",
                    hasChevron: true,
                    action: {}
                )
            }
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Food Delivery Section
    private var foodDeliverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Red Indicator
            HStack(spacing: 8) {
                Capsule()
                    .fill(Color(red: 0.9, green: 0.1, blue: 0.2))
                    .frame(width: 3.5, height: 18)
                Text("Food delivery")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            
            // Card Content
            VStack(spacing: 0) {
                preferenceRow(
                    iconName: "bag",
                    title: "Your orders",
                    hasChevron: true,
                    action: {}
                )
                
                Divider().padding(.leading, 52)
                
                preferenceRow(
                    iconName: "house",
                    title: "Address book",
                    hasChevron: true,
                    action: {}
                )
                
                Divider().padding(.leading, 52)
                
                preferenceRow(
                    iconName: "bookmark",
                    title: "Your collections",
                    hasChevron: true,
                    action: {}
                )
            }
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Helper Preference Row
    @ViewBuilder
    private func preferenceRow(
        iconName: String? = nil,
        customIcon: AnyView? = nil,
        title: String,
        trailingText: String? = nil,
        hasChevron: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let custom = customIcon {
                    custom.frame(width: 24)
                } else if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let text = trailingText {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Custom Veg Icon (Green Square with Green Dot inside)
    private var vegIcon: AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.green, lineWidth: 1.5)
                    .frame(width: 15, height: 15)
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
            }
        )
    }
}

#Preview {
    ZomatoProfileView()
}
