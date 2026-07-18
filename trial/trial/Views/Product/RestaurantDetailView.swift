//
//  RestaurantDetailView.swift
//  trial
//
//  Full Zomato restaurant detail with full-bleed hero image header & floating search pill (Image 2 style).
//

import SwiftUI

public struct RestaurantDetailView: View {
    @StateObject private var viewModel: ZomatoRestaurantViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCart = false
    @State private var selectedFilter: String? = nil
    @State private var isRecommendedExpanded = true
    @State private var isSearchFocused = false
    
    public init(restaurant: Restaurant) {
        _viewModel = StateObject(wrappedValue: ZomatoRestaurantViewModel(restaurant: restaurant))
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Full-Bleed Hero Image Header (Covers top safe area)
                        fullBleedHeroHeader
                        
                        // White Overlapping Restaurant Info Card
                        restaurantInfoCard
                            .offset(y: -24)
                            .padding(.bottom, -24)
                        
                        Divider().padding(.top, 12)
                        
                        // Filter Chips Row
                        inRestaurantFiltersRow
                            .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Category / Menu Sections
                        ForEach(viewModel.menuSections, id: \.0) { section in
                            collapsibleMenuSection(title: section.0, items: section.1)
                        }
                        
                        Spacer().frame(height: 120)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .navigationBarBackButtonHidden(true)
                
                // Sticky View Cart Button
                if viewModel.cartService.totalItemCount > 0 && viewModel.cartService.currentRestaurantId == viewModel.restaurant.id {
                    stickyCartButton
                }
            }
            
            // Floating Menu Pill (Bottom Right)
            floatingMenuButton
                .padding(.trailing, 20)
                .padding(.bottom, viewModel.cartService.totalItemCount > 0 ? 80 : 24)
        }
        .sheet(isPresented: $viewModel.showCustomizationSheet) {
            CustomizationSheet(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showCart) {
            ZomatoCartView()
        }
    }
    
    // MARK: - Full Bleed Hero Header
    private var fullBleedHeroHeader: some View {
        ZStack(alignment: .top) {
            // Hero Image
            ZStack(alignment: .bottom) {
                Image(viewModel.restaurant.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                LinearGradient(colors: [.black.opacity(0.6), .clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                
                // Bottom Caption & Carousel Dots
                VStack(spacing: 8) {
                    HStack {
                        Text("Big Big 6in1 Pizza - Veg")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Page Dots
                    HStack(spacing: 5) {
                        ForEach(0..<8, id: \.self) { i in
                            Circle()
                                .fill(i == 0 ? Color.white : Color.white.opacity(0.4))
                                .frame(width: i == 0 ? 7 : 5, height: i == 0 ? 7 : 5)
                        }
                    }
                }
                .padding(.bottom, 36)
            }
            
            // Top Floating Navigation Bar Controls
            HStack {
                // Back Button (Floating Circle)
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.45))
                            .frame(width: 38, height: 38)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Search Pill Button (Image 2 style: Small Search Circle/Pill)
                Button(action: {
                    withAnimation(.spring()) {
                        isSearchFocused.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .bold))
                        Text("Search")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Capsule())
                }
                
                // Ellipsis Options Button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.45))
                            .frame(width: 38, height: 38)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 54) // Safely below iPhone dynamic island/notch
        }
    }
    
    // MARK: - Overlapping Restaurant Info Card (White Container)
    private var restaurantInfoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Grab handle bar
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 4)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Title & Rating
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(viewModel.restaurant.name)
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                        Text("\(viewModel.restaurant.distance) • Subhash Nagar")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("\(viewModel.restaurant.deliveryTime)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.green)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Schedule for later")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Rating Badge (Image 2 style)
                VStack(spacing: 2) {
                    HStack(spacing: 3) {
                        Text(String(format: "%.1f", viewModel.restaurant.rating))
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.1, green: 0.55, blue: 0.3))
                    .cornerRadius(10)
                    
                    Text("For you")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // Badges Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                        Text("On-time preparation")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.06))
                    .cornerRadius(8)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                        Text("Low plastic packaging")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.06))
                    .cornerRadius(8)
                }
            }
            .padding(.top, 4)
            
            // Search Input expansion if activated
            if isSearchFocused {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                    TextField("Search within menu", text: $viewModel.searchText)
                        .font(.system(size: 15))
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color.white)
        .cornerRadius(28, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -4)
    }
    
    // MARK: - In-Restaurant Filters Row
    private var inRestaurantFiltersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Filters dropdown
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3").font(.system(size: 12))
                    Text("Filters").font(.system(size: 13, weight: .medium))
                    Image(systemName: "arrowtriangle.down.fill").font(.system(size: 7)).foregroundColor(.gray)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.white).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                // Veg filter chip
                Button(action: { viewModel.vegOnly.toggle() }) {
                    HStack(spacing: 6) {
                        vegIcon
                        Text("Veg").font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(viewModel.vegOnly ? Color(red: 0.9, green: 0.1, blue: 0.2) : .primary)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(viewModel.vegOnly ? Color(red: 1.0, green: 0.94, blue: 0.95) : Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(viewModel.vegOnly ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.3), lineWidth: 1))
                }
                
                // Non-veg filter chip
                HStack(spacing: 6) {
                    nonVegIcon
                    Text("Non-veg").font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.white).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                // Highly reordered filter chip
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Text("Highly reordered").font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.white).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Collapsible Menu Section
    private func collapsibleMenuSection(title: String, items: [MenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Accordion Title Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if title.contains("Recommended") {
                        isRecommendedExpanded.toggle()
                    }
                }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("(\(items.count))")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: isRecommendedExpanded || !title.contains("Recommended") ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isRecommendedExpanded || !title.contains("Recommended") {
                ForEach(items) { item in
                    VStack(spacing: 0) {
                        menuItemRow(item)
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
        }
    }
    
    // MARK: - Menu Item Row
    private func menuItemRow(_ item: MenuItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Left Column: Details
            VStack(alignment: .leading, spacing: 6) {
                // Veg/Non-Veg & Spicy Icons
                HStack(spacing: 6) {
                    if item.isVeg {
                        vegIcon
                    } else {
                        nonVegIcon
                    }
                    
                    if item.name.lowercased().contains("tikka") || item.name.lowercased().contains("peri") || item.name.lowercased().contains("spicy") {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                }
                
                // Item Name
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                // Highly Reordered Indicator Bar
                if item.isHighlyOrdered || item.isBestseller {
                    HStack(spacing: 6) {
                        Capsule()
                            .fill(Color.green)
                            .frame(width: 32, height: 4)
                        Text("Highly reordered")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Price
                Text("₹\(Int(item.price))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                // Description with "... more"
                if let desc = item.description {
                    (Text(desc + " ").font(.system(size: 13)).foregroundColor(.secondary) +
                     Text("more").font(.system(size: 13, weight: .bold)).foregroundColor(.primary))
                        .lineLimit(2)
                }
                
                // Action Buttons: Bookmark & Share
                HStack(spacing: 12) {
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 32, height: 32)
                            Image(systemName: "bookmark")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 32, height: 32)
                            Image(systemName: "arrowshape.turn.up.forward")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer(minLength: 8)
            
            // Right Column: Image + ADD Button Overlay
            VStack(spacing: 6) {
                ZStack(alignment: .bottom) {
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Overlaid ADD Button
                    let qty = viewModel.quantityInCart(for: item)
                    if qty > 0 {
                        // Stepper (- 1 +)
                        HStack(spacing: 14) {
                            Button(action: {
                                if let cartItem = viewModel.cartService.items.first(where: { $0.menuItem.id == item.id }) {
                                    viewModel.cartService.updateQuantity(for: cartItem.id, quantity: cartItem.quantity - 1)
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .black))
                            }
                            
                            Text("\(qty)")
                                .font(.system(size: 15, weight: .black))
                            
                            Button(action: { viewModel.prepareCustomization(for: item) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .black))
                            }
                        }
                        .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.96))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.9, green: 0.1, blue: 0.2), lineWidth: 1.5)
                        )
                        .offset(y: 16)
                    } else {
                        // ADD + Button
                        Button(action: { viewModel.prepareCustomization(for: item) }) {
                            HStack(spacing: 4) {
                                Text("ADD")
                                    .font(.system(size: 16, weight: .black))
                                Text("+")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color(red: 1.0, green: 0.96, blue: 0.97))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.9, green: 0.1, blue: 0.2), lineWidth: 1.5)
                            )
                        }
                        .offset(y: 16)
                    }
                }
                .padding(.bottom, 16)
                
                // Customisable subtitle
                if item.isCustomisable {
                    Text("customisable")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Floating Menu Button (Bottom Right)
    private var floatingMenuButton: some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 14, weight: .bold))
                Text("Menu")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Sticky Cart Button
    private var stickyCartButton: some View {
        Button(action: { showCart = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.cartService.totalItemCount) item\(viewModel.cartService.totalItemCount > 1 ? "s" : "") added")
                        .font(.system(size: 14, weight: .bold))
                    Text("₹\(Int(viewModel.cartService.grandTotal))")
                        .font(.system(size: 12, weight: .medium)).opacity(0.9)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("VIEW CART").font(.system(size: 14, weight: .heavy))
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(red: 0.9, green: 0.1, blue: 0.2))
            .cornerRadius(14)
            .shadow(color: Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Icons
    private var vegIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.green, lineWidth: 1.5)
                .frame(width: 14, height: 14)
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
        }
    }
    
    private var nonVegIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.red, lineWidth: 1.5)
                .frame(width: 14, height: 14)
            Image(systemName: "triangle.fill")
                .font(.system(size: 6))
                .foregroundColor(.red)
        }
    }
}

// MARK: - Customization Bottom Sheet

struct CustomizationSheet: View {
    @ObservedObject var viewModel: ZomatoRestaurantViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var quantity: Int = 1
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Floating Close Button Header
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.8))
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Item Title Card
                        if let item = viewModel.selectedMenuItem {
                            HStack(spacing: 12) {
                                Image(item.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(item.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "bookmark")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "arrowshape.turn.up.forward")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(18)
                        }
                        
                        // Customization Option Groups
                        ForEach($viewModel.customizationGroups) { $group in
                            VStack(alignment: .leading, spacing: 14) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(group.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(group.isRequired ? "Required • Select any 1 option" : "Select up to \(group.maxSelections) option")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                ForEach(group.options) { option in
                                    Button(action: {
                                        viewModel.toggleOption(groupId: group.id, optionId: option.id)
                                        BlinkitTheme.triggerHaptic(.light)
                                    }) {
                                        HStack(spacing: 10) {
                                            if option.name.lowercased().contains("crust") || option.name.lowercased().contains("burst") || option.name.lowercased().contains("tossed") {
                                                vegDotIcon
                                            }
                                            
                                            Text(option.name)
                                                .font(.system(size: 15, weight: option.isSelected ? .bold : .regular))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if option.price > 0 {
                                                Text("₹\(Int(option.price))")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            // Red Selection Ring / Radio Button
                                            ZStack {
                                                Circle()
                                                    .stroke(Color(red: 0.9, green: 0.1, blue: 0.2), lineWidth: 1.5)
                                                    .frame(width: 22, height: 22)
                                                
                                                if option.isSelected {
                                                    Circle()
                                                        .fill(Color(red: 0.9, green: 0.1, blue: 0.2))
                                                        .frame(width: 13, height: 13)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(18)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                }
                
                // Bottom Fixed Add Item Bar
                bottomAddItemBar
            }
        }
    }
    
    // Bottom Bar (Quantity Stepper + Add Item Red Button)
    private var bottomAddItemBar: some View {
        HStack(spacing: 16) {
            // Stepper (- 1 +)
            HStack(spacing: 16) {
                Button(action: {
                    if quantity > 1 { quantity -= 1 }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                }
                
                Text("\(quantity)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.primary)
                
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 1.0, green: 0.95, blue: 0.96))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.9, green: 0.1, blue: 0.2), lineWidth: 1)
            )
            
            // Add Item Red Button
            Button(action: {
                for _ in 0..<quantity {
                    viewModel.addToCartWithCustomizations()
                }
                dismiss()
            }) {
                Text("Add item - ₹\(Int(viewModel.customizationTotal * Double(quantity)))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.9, green: 0.1, blue: 0.2))
                    .cornerRadius(14)
                    .shadow(color: Color(red: 0.9, green: 0.1, blue: 0.2).opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -4)
    }
    
    private var vegDotIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.green, lineWidth: 1.5)
                .frame(width: 14, height: 14)
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
        }
    }
}
