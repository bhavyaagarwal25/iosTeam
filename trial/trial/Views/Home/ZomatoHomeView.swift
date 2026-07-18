//
//  ZomatoHomeView.swift
//  trial
//
//  Production-ready Zomato home screen
//

import SwiftUI

public struct ZomatoHomeView: View {
    @StateObject private var viewModel = ZomatoHomeViewModel()
    @State private var showSearch = false
    @State private var showCart = false
    @State private var showProfile = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header section based on tab
                        if viewModel.selectedBottomTab == .under250 {
                            blueHeaderSection
                        } else {
                            redHeaderSection
                        }
                        
                        // White content
                        VStack(spacing: 20) {
                            categoriesView
                            quickFiltersView
                            
                            if !viewModel.isAnyFilterActive {
                                if !viewModel.recommendedRestaurants.isEmpty {
                                    recommendedDealsView
                                }
                                
                                if !viewModel.featuredRestaurants.isEmpty {
                                    featuredRestaurantsView
                                }
                                
                                collectionsView
                            } else {
                                // Active filter summary bar
                                HStack {
                                    Text("Filtered Results (\(viewModel.filteredRestaurants.count))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Button(action: { viewModel.clearAllFilters() }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "xmark.circle.fill").font(.system(size: 13))
                                            Text("Clear All").font(.system(size: 13, weight: .bold))
                                        }
                                        .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.06))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                            }
                            
                            allRestaurantsView
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.top, 16)
                        .background(Color(uiColor: .systemBackground))
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Cart floating bar
                if viewModel.cartService.totalItemCount > 0 {
                    cartFloatingBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 80)
                }
                
                // Bottom pill
                floatingBottomPill
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showSearch) {
                ZomatoSearchView()
            }
            .fullScreenCover(isPresented: $showCart) {
                ZomatoCartView()
            }
            .fullScreenCover(isPresented: $showProfile) {
                NavigationStack { ZomatoProfileView() }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                ZomatoFilterSheetView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Red Header
    private var redHeaderSection: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(red: 0.9, green: 0.1, blue: 0.2), Color(red: 0.8, green: 0.05, blue: 0.15)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: 360)
            
            // Sunburst
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.55)
                ZStack {
                    ForEach(0..<16, id: \.self) { i in
                        Path { path in
                            path.move(to: center)
                            let a1 = (Double(i) * 22.5 - 6) * .pi / 180
                            let a2 = (Double(i) * 22.5 + 6) * .pi / 180
                            path.addLine(to: CGPoint(x: center.x + cos(a1) * 500, y: center.y + sin(a1) * 500))
                            path.addLine(to: CGPoint(x: center.x + cos(a2) * 500, y: center.y + sin(a2) * 500))
                            path.closeSubpath()
                        }
                        .fill(Color.white.opacity(0.06))
                    }
                }
            }
            .frame(height: 360)
            .clipped()
            
            VStack(spacing: 12) {
                headerBar()
                searchBar
                bannerContent
                bannerDots
            }
        }
    }
    
    // MARK: - Blue Header
    private var blueHeaderSection: some View {
        ZStack(alignment: .bottom) {
            // Blue Striped background
            GeometryReader { geo in
                HStack(spacing: 4) {
                    ForEach(0..<Int(geo.size.width / 8), id: \.self) { _ in
                        Rectangle().fill(Color.white.opacity(0.2)).frame(width: 4)
                    }
                }
            }
            .background(LinearGradient(colors: [Color(red: 0.65, green: 0.85, blue: 1.0), Color(red: 0.85, green: 0.92, blue: 1.0)], startPoint: .top, endPoint: .bottom))
            .ignoresSafeArea(edges: .top)
            .frame(height: 200)
            
            VStack(spacing: 12) {
                headerBar(textColor: Color(red: 0.1, green: 0.2, blue: 0.4))
                
                // Meals Under 250 Banner
                VStack(spacing: 0) {
                    Text("MEALS UNDER ₹250")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.98, green: 0.93, blue: 0.88))
                        .overlay(
                            Rectangle().stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .zIndex(1)
                    
                    Text("FINAL PRICE, BEST OFFER APPLIED")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Header Bar
    private func headerBar(textColor: Color = .white) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Home").font(.system(size: 20, weight: .bold))
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold))
                }
                Text("Panchayti mandir, Subhash N...")
                    .font(.system(size: 13, weight: .medium))
                    .opacity(0.9)
                    .padding(.leading, 20)
            }
            .foregroundColor(textColor)
            
            Spacer()
            
            HStack(spacing: 10) {
                VStack(spacing: -1) {
                    Text("GOLD").font(.system(size: 9, weight: .black))
                    Text("₹1").font(.system(size: 11, weight: .black))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(Color(red: 0.96, green: 0.82, blue: 0.15)))
                
                Button(action: {}) {
                    Circle().fill(Color.black.opacity(0.15)).frame(width: 36, height: 36)
                        .overlay(Image(systemName: "bell.fill").foregroundColor(textColor).font(.system(size: 15)))
                }
                
                Button(action: { showProfile = true }) {
                    Circle().fill(Color(red: 0.3, green: 0.5, blue: 0.9)).frame(width: 36, height: 36)
                        .overlay(Text("S").font(.system(size: 16, weight: .bold)).foregroundColor(.white))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 54)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Button(action: { showSearch = true }) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.red).font(.system(size: 18, weight: .semibold))
                    Text("Search \"binge night\"").font(.system(size: 16)).foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "mic.fill").foregroundColor(.red).font(.system(size: 18))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.white).cornerRadius(14)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            
            VStack(spacing: 3) {
                Text("VEG").font(.system(size: 9, weight: .heavy)).foregroundColor(.white)
                Text("MODE").font(.system(size: 9, weight: .heavy)).foregroundColor(.white)
                Toggle("", isOn: $viewModel.vegModeEnabled).labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green)).scaleEffect(0.7)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Banner
    private var bannerContent: some View {
        let banner = viewModel.banners[viewModel.currentBannerIndex]
        return VStack(spacing: -4) {
            Text(banner.title)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                .italic()
                .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)
            Text(banner.subtitle)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .italic()
                .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)
            
            if let badge = banner.badgeText {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text(badge).font(.system(size: 14, weight: .bold))
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 9)
                    .background(Color.black).clipShape(Capsule())
                }
                .padding(.top, 10)
            }
        }
        .id(viewModel.currentBannerIndex)
        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
    }
    
    private var bannerDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.banners.count, id: \.self) { i in
                Circle()
                    .fill(i == viewModel.currentBannerIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(width: i == viewModel.currentBannerIndex ? 8 : 6, height: i == viewModel.currentBannerIndex ? 8 : 6)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentBannerIndex)
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Categories
    private var categoriesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // Explore ₹250 card
                if viewModel.selectedBottomTab != .under250 {
                    VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(colors: [Color(red: 0.0, green: 0.35, blue: 0.25), Color(red: 0.0, green: 0.45, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 65, height: 65)
                        VStack(spacing: 2) {
                            Text("MEALS UNDER").font(.system(size: 7, weight: .heavy)).foregroundColor(.white.opacity(0.8))
                            Text("₹250").font(.system(size: 16, weight: .black)).foregroundColor(.white)
                            HStack(spacing: 2) {
                                Text("Explore").font(.system(size: 9, weight: .semibold))
                                Image(systemName: "chevron.right").font(.system(size: 7, weight: .bold))
                            }.foregroundColor(.white.opacity(0.9))
                        }
                    }
                    Text(" ").font(.system(size: 12))
                    Capsule().fill(Color.clear).frame(height: 3)
                }
                .padding(.trailing, 12)
                }
                
                ForEach(viewModel.categories) { category in
                    let isSelected = category == viewModel.selectedCategory
                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .overlay(
                                Group {
                                    if category == .all {
                                        Image(systemName: "square.grid.2x2.fill").foregroundColor(.red).font(.system(size: 26))
                                    } else {
                                        Text(category.iconName).font(.system(size: 32))
                                    }
                                }
                            )
                        
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .primary : .secondary)
                            .lineLimit(1)
                        
                        Capsule()
                            .fill(isSelected ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.clear)
                            .frame(width: 44, height: 3)
                    }
                    .padding(.horizontal, 8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Quick Filters
    private var quickFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Filters button
                let hasActiveFilters = viewModel.activeFiltersCount > 0
                Button(action: { viewModel.showFilterSheet = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 13))
                            .foregroundColor(hasActiveFilters ? Color(red: 0.9, green: 0.1, blue: 0.2) : .primary)
                        
                        Text("Filters\(hasActiveFilters ? " (\(viewModel.activeFiltersCount))" : "")")
                            .font(.system(size: 14, weight: hasActiveFilters ? .bold : .medium))
                            .foregroundColor(hasActiveFilters ? Color(red: 0.15, green: 0.15, blue: 0.15) : .primary)
                        
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundColor(hasActiveFilters ? Color(red: 0.9, green: 0.1, blue: 0.2) : .gray)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(hasActiveFilters ? Color(red: 1.0, green: 0.93, blue: 0.94) : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasActiveFilters ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.25), lineWidth: 1.2)
                    )
                }
                
                // Sort Menu
                let isSorted = viewModel.sortOption != .relevance
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button(action: { viewModel.sortOption = option }) {
                            HStack {
                                Text(option.rawValue)
                                if viewModel.sortOption == option { Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 12))
                            .foregroundColor(isSorted ? Color(red: 0.9, green: 0.1, blue: 0.2) : .gray)
                        
                        Text(isSorted ? viewModel.sortOption.rawValue : "Sort")
                            .font(.system(size: 14, weight: isSorted ? .bold : .medium))
                            .foregroundColor(isSorted ? Color(red: 0.15, green: 0.15, blue: 0.15) : .primary)
                        
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundColor(isSorted ? Color(red: 0.9, green: 0.1, blue: 0.2) : .gray)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isSorted ? Color(red: 1.0, green: 0.93, blue: 0.94) : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSorted ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.25), lineWidth: 1.2)
                    )
                }
                
                // Individual Quick Filters
                ForEach(QuickFilter.allCases) { filter in
                    let isActive = viewModel.isFilterActive(filter)
                    Button(action: { viewModel.toggleFilter(filter) }) {
                        HStack(spacing: 6) {
                            if let icon = filter.iconName {
                                Image(systemName: icon)
                                    .font(.system(size: 12))
                                    .foregroundColor(isActive ? Color(red: 0.9, green: 0.1, blue: 0.2) : filter.iconColor)
                            }
                            
                            Text(filter.rawValue)
                                .font(.system(size: 14, weight: isActive ? .bold : .medium))
                                .foregroundColor(isActive ? Color(red: 0.15, green: 0.15, blue: 0.15) : .primary)
                            
                            if isActive {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.2))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isActive ? Color(red: 1.0, green: 0.93, blue: 0.94) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isActive ? Color(red: 0.9, green: 0.1, blue: 0.2) : Color.gray.opacity(0.25), lineWidth: 1.2)
                        )
                    }
                }
                
                // Schedule dropdown
                HStack(spacing: 6) {
                    Text("Schedule")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1.2)
                )
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Recommended With Deals
    private var recommendedDealsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECOMMENDED WITH DEALS")
                .font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).tracking(1.5)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.recommendedRestaurants) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            restaurantCardSmall(restaurant)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Featured Restaurants
    private var featuredRestaurantsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FEATURED RESTAURANTS")
                .font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).tracking(1.5)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredRestaurants) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            featuredCard(restaurant)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Collections
    private var collectionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COLLECTIONS")
                .font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).tracking(1.5)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    collectionCard(title: "Top Rated", subtitle: "\(viewModel.dataService.topRatedRestaurants.count) places", icon: "star.fill", color: .orange)
                    collectionCard(title: "New Arrivals", subtitle: "Freshly added", icon: "sparkles", color: .purple)
                    collectionCard(title: "Budget Eats", subtitle: "Under ₹200", icon: "indianrupeesign.circle.fill", color: .green)
                    collectionCard(title: "Premium Dining", subtitle: "Fine dining", icon: "crown.fill", color: .yellow)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - All Restaurants
    private var allRestaurantsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(viewModel.filteredRestaurants.count) RESTAURANTS DELIVERING TO YOU")
                .font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).tracking(1.5)
                .padding(.horizontal, 16)
            
            if viewModel.filteredRestaurants.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.top, 20)
                    
                    Text("No restaurants found")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("Try clearing or changing your filters to find delicious places near you.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: { viewModel.clearAllFilters() }) {
                        Text("Reset All Filters")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredRestaurants) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            restaurantCardLarge(restaurant)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Cart Floating Bar
    private var cartFloatingBar: some View {
        Button(action: { showCart = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.cartService.totalItemCount) item\(viewModel.cartService.totalItemCount > 1 ? "s" : "") added")
                        .font(.system(size: 14, weight: .bold))
                    Text(viewModel.cartService.currentRestaurantName ?? "")
                        .font(.system(size: 12, weight: .medium)).opacity(0.9)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("VIEW CART").font(.system(size: 14, weight: .heavy))
                    Image(systemName: "bag.fill").font(.system(size: 14))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(Color.green)
            .cornerRadius(12)
            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Bottom Pill (Matches Screenshot Design)
    private var floatingBottomPill: some View {
        HStack(spacing: 6) {
            ForEach(ZomatoBottomTab.allCases) { tab in
                let isSelected = viewModel.selectedBottomTab == tab
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.selectBottomTab(tab)
                    }
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    }
                    .foregroundColor(isSelected ? Color(red: 0.9, green: 0.1, blue: 0.2) : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.93, blue: 0.94))
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 5)
        .overlay(Capsule().stroke(Color.gray.opacity(0.18), lineWidth: 1))
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Card Components
    
    private func restaurantCardSmall(_ r: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                Image(r.imageName).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150).cornerRadius(16).clipped()
                
                if let offer = r.offer {
                    VStack {
                        Text(offer).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.blue).cornerRadius(4, corners: [.topRight, .bottomRight])
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                
                HStack(spacing: 3) {
                    Text(String(format: "%.1f", r.rating)).font(.system(size: 12, weight: .bold))
                    Image(systemName: "star.fill").font(.system(size: 8))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 6).padding(.vertical, 4)
                .background(Color.green).cornerRadius(6).padding(8)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(r.name).font(.system(size: 15, weight: .bold)).lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill").foregroundColor(.green).font(.system(size: 10))
                    Text(r.deliveryTime).font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                }
            }.frame(width: 150, alignment: .leading)
        }
    }
    
    private func featuredCard(_ r: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                Image(r.imageName).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 260, height: 160).cornerRadius(16).clipped()
                
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    if r.isSponsored {
                        Text("SPONSORED").font(.system(size: 9, weight: .bold)).foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.white.opacity(0.2)).cornerRadius(4)
                    }
                    Text(r.name).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text(r.cuisineText).font(.system(size: 12)).foregroundColor(.white.opacity(0.9))
                }.padding(12)
            }
            
            HStack {
                HStack(spacing: 3) {
                    Text(String(format: "%.1f", r.rating)).font(.system(size: 13, weight: .bold))
                    Image(systemName: "star.fill").font(.system(size: 9))
                }.foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 3).background(Color.green).cornerRadius(5)
                
                Text("•").foregroundColor(.secondary)
                Text(r.deliveryTime).font(.system(size: 13)).foregroundColor(.secondary)
                Text("•").foregroundColor(.secondary)
                Text("₹\(r.priceForTwo) for two").font(.system(size: 13)).foregroundColor(.secondary)
            }
        }.frame(width: 260)
    }
    
    private func collectionCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.1)).frame(width: 140, height: 80)
                Image(systemName: icon).font(.system(size: 30)).foregroundColor(color)
            }
            Text(title).font(.system(size: 14, weight: .bold))
            Text(subtitle).font(.system(size: 12)).foregroundColor(.secondary)
        }.frame(width: 140)
    }
    
    private func restaurantCardLarge(_ r: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(r.imageName).resizable().aspectRatio(contentMode: .fill)
                    .frame(height: 200).cornerRadius(16).clipped()
                
                Button(action: {}) {
                    Image(systemName: r.isFavorite ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20)).foregroundColor(.white).padding(16)
                        .shadow(color: .black, radius: 2)
                }
                
                VStack(alignment: .leading) {
                    if r.isSponsored {
                        HStack {
                            Spacer()
                            Text("AD").font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.black.opacity(0.5)).cornerRadius(4)
                                .padding(.trailing, 50).padding(.top, 12)
                        }
                    }
                    Spacer()
                    if let offer = r.offer {
                        Text(offer).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(8, corners: [.topRight, .bottomRight])
                            .padding(.bottom, 16)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(r.name).font(.system(size: 20, weight: .bold))
                    Text(r.cuisineText).font(.system(size: 13)).foregroundColor(.secondary).lineLimit(1)
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill").foregroundColor(.green)
                            Text(r.deliveryTime)
                        }
                        Text("•")
                        Text(r.distance)
                        Text("•")
                        Text("₹\(r.priceForTwo) for two")
                    }.font(.system(size: 13, weight: .medium)).foregroundColor(.secondary)
                    
                    if r.isPureVeg {
                        HStack(spacing: 4) {
                            Image(systemName: "leaf.fill").foregroundColor(.green)
                            Text("Pure Veg")
                        }.font(.system(size: 12, weight: .medium)).foregroundColor(.green)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.green.opacity(0.1)).cornerRadius(6)
                    }
                }
                
                Spacer()
                
                VStack {
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", r.rating))
                        Image(systemName: "star.fill").font(.system(size: 10))
                    }.font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 6).background(Color.green).cornerRadius(8)
                    
                    Text("\(r.numberOfRatings)+ ratings").font(.system(size: 10)).foregroundColor(.secondary)
                }
            }
        }
        .padding().background(Color(uiColor: .systemBackground)).cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// Keep corner radius extension here for backward compat
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

func categoryEmoji(for category: ZomatoCategory) -> String {
    category.iconName
}

#Preview { ZomatoHomeView() }

// MARK: - Filter Sheet View

struct ZomatoFilterSheetView: View {
    @ObservedObject var viewModel: ZomatoHomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    sortBySection
                    Divider()
                    quickFiltersSection
                    Divider()
                    categoriesSection
                }
                .padding(20)
            }
            .navigationTitle("Filters & Sorting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearAllFilters()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var sortBySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SORT BY")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1.2)
            
            VStack(spacing: 8) {
                ForEach(SortOption.allCases, id: \.id) { (option: SortOption) in
                    Button(action: {
                        viewModel.sortOption = option
                        BlinkitTheme.triggerHaptic(.light)
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .font(.system(size: 15, weight: viewModel.sortOption == option ? .bold : .regular))
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.sortOption == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18))
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(viewModel.sortOption == option ? Color.red.opacity(0.05) : Color.gray.opacity(0.04))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var quickFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK FILTERS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1.2)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(QuickFilter.allCases, id: \.id) { (filter: QuickFilter) in
                    Button(action: {
                        viewModel.toggleFilter(filter)
                    }) {
                        HStack(spacing: 8) {
                            if let icon = filter.iconName {
                                Image(systemName: icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(viewModel.isFilterActive(filter) ? .white : filter.iconColor)
                            }
                            Text(filter.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .lineLimit(1)
                            Spacer()
                            if viewModel.isFilterActive(filter) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .foregroundColor(viewModel.isFilterActive(filter) ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(viewModel.isFilterActive(filter) ? Color.red : Color.gray.opacity(0.06))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.isFilterActive(filter) ? Color.red : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CUISINES & CATEGORIES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1.2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories, id: \.id) { (category: ZomatoCategory) in
                        Button(action: {
                            viewModel.selectedCategory = category
                            BlinkitTheme.triggerHaptic(.light)
                        }) {
                            HStack(spacing: 6) {
                                Text(category.iconName).font(.system(size: 16))
                                Text(category.rawValue).font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCategory == category ? Color.red : Color.gray.opacity(0.06))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
}
