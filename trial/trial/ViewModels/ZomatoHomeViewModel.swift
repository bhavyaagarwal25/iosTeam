//
//  ZomatoHomeViewModel.swift
//  trial
//

import Foundation
import Combine
import SwiftUI

@MainActor
public class ZomatoHomeViewModel: ObservableObject {
    @Published public var selectedCategory: ZomatoCategory = .all
    @Published public var searchText: String = ""
    @Published public var vegModeEnabled: Bool = false
    @Published public var currentBannerIndex: Int = 0
    @Published public var selectedBottomTab: ZomatoBottomTab = .delivery
    
    // Filters
    @Published public var filterNearFast: Bool = false
    @Published public var filterRating4Plus: Bool = false
    @Published public var filterUnder200: Bool = false
    @Published public var filterOpenNow: Bool = false
    @Published public var filterHasOffers: Bool = false
    @Published public var sortOption: SortOption = .relevance
    
    public let dataService: ZomatoDataService
    public let cartService: ZomatoCartService
    
    private var bannerTimer: Timer?
    
    public init() {
        self.dataService = ZomatoDataService.shared
        self.cartService = ZomatoCartService.shared
        startBannerTimer()
    }
    
    @Published public var showFilterSheet: Bool = false
    
    public var isAnyFilterActive: Bool {
        selectedCategory != .all || vegModeEnabled || filterNearFast || filterRating4Plus || filterUnder200 || filterOpenNow || filterHasOffers || sortOption != .relevance
    }
    
    public var activeFiltersCount: Int {
        var count = 0
        if selectedCategory != .all { count += 1 }
        if vegModeEnabled { count += 1 }
        if filterNearFast { count += 1 }
        if filterRating4Plus { count += 1 }
        if filterUnder200 { count += 1 }
        if filterOpenNow { count += 1 }
        if filterHasOffers { count += 1 }
        if sortOption != .relevance { count += 1 }
        return count
    }
    
    public var filteredRestaurants: [Restaurant] {
        dataService.filteredRestaurants(
            category: selectedCategory,
            vegOnly: vegModeEnabled,
            rating4Plus: filterRating4Plus,
            openOnly: filterOpenNow,
            under200: filterUnder200,
            nearFast: filterNearFast,
            hasOffers: filterHasOffers,
            searchQuery: searchText,
            sortBy: sortOption
        )
    }
    
    public var recommendedRestaurants: [Restaurant] {
        dataService.restaurantsWithOffers
    }
    
    public var featuredRestaurants: [Restaurant] {
        dataService.featuredRestaurants
    }
    
    public var banners: [ZomatoBanner] {
        dataService.allBanners
    }
    
    public var categories: [ZomatoCategory] {
        [.all, .pizza, .burger, .chinese, .biryani, .southIndian, .italian, .rolls, .desserts, .coffee, .healthy, .paratha, .northIndian, .thali, .streetFood]
    }
    
    // MARK: - Banner Auto-Scroll
    
    public func startBannerTimer() {
        bannerTimer?.invalidate()
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.currentBannerIndex = (self.currentBannerIndex + 1) % self.banners.count
                }
            }
        }
    }
    
    public func stopBannerTimer() {
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    
    // MARK: - Filter Toggles
    
    public func toggleFilter(_ filter: QuickFilter) {
        switch filter {
        case .nearFast: filterNearFast.toggle()
        case .rating4Plus: filterRating4Plus.toggle()
        case .under200: filterUnder200.toggle()
        case .openNow: filterOpenNow.toggle()
        case .offers: filterHasOffers.toggle()
        case .pureVeg: vegModeEnabled.toggle()
        }
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public func isFilterActive(_ filter: QuickFilter) -> Bool {
        switch filter {
        case .nearFast: return filterNearFast
        case .rating4Plus: return filterRating4Plus
        case .under200: return filterUnder200
        case .openNow: return filterOpenNow
        case .offers: return filterHasOffers
        case .pureVeg: return vegModeEnabled
        }
    }
    
    public func selectBottomTab(_ tab: ZomatoBottomTab) {
        selectedBottomTab = tab
        switch tab {
        case .delivery:
            filterUnder200 = false
        case .under250:
            filterUnder200 = true
        case .dining:
            filterUnder200 = false
            filterRating4Plus = true
        }
        BlinkitTheme.triggerHaptic(.light)
    }
    
    public func clearAllFilters() {
        selectedCategory = .all
        vegModeEnabled = false
        filterNearFast = false
        filterRating4Plus = false
        filterUnder200 = false
        filterOpenNow = false
        filterHasOffers = false
        sortOption = .relevance
        selectedBottomTab = .delivery
    }
    
    deinit {
        bannerTimer?.invalidate()
    }
}

public enum ZomatoBottomTab: String, CaseIterable, Identifiable {
    case delivery = "Delivery"
    case under250 = "Under ₹250"
    case dining = "Dining"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .delivery: return "figure.outdoor.cycle"
        case .under250: return "tag.fill"
        case .dining: return "fork.knife"
        }
    }
}

public enum QuickFilter: String, CaseIterable, Identifiable {
    case nearFast = "Near & Fast"
    case pureVeg = "Pure Veg"
    case rating4Plus = "Rating 4.0+"
    case openNow = "Open Now"
    case under200 = "Under ₹200"
    case offers = "Offers"
    
    public var id: String { rawValue }
    
    public var iconName: String? {
        switch self {
        case .nearFast: return "bolt.fill"
        case .pureVeg: return "leaf.fill"
        default: return nil
        }
    }
    
    public var iconColor: Color {
        switch self {
        case .nearFast: return .green
        case .pureVeg: return .green
        default: return .primary
        }
    }
}
