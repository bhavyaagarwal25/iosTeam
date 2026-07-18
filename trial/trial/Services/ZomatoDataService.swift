//
//  ZomatoDataService.swift
//  trial
//

import Foundation
import Combine
import UIKit

@MainActor
public class ZomatoDataService: ObservableObject {
    public static let shared = ZomatoDataService()
    
    public let allRestaurants: [Restaurant] = MockZomatoData.restaurants
    public let allBanners: [ZomatoBanner] = MockZomatoData.banners
    public let allCoupons: [ZomatoCoupon] = MockZomatoData.coupons
    public let allAddresses: [ZomatoAddress] = MockZomatoData.addresses
    public let allOffers: [ZomatoOffer] = MockZomatoData.offers
    
    public init() {}
    
    // MARK: - Restaurant Filtering
    
    public func filteredRestaurants(
        category: ZomatoCategory = .all,
        vegOnly: Bool = false,
        rating4Plus: Bool = false,
        openOnly: Bool = false,
        under200: Bool = false,
        nearFast: Bool = false,
        hasOffers: Bool = false,
        searchQuery: String = "",
        sortBy: SortOption = .relevance
    ) -> [Restaurant] {
        var results = allRestaurants
        
        // Category filter
        if category != .all {
            results = results.filter { $0.categories.contains(category) }
        }
        
        // Veg filter (pure veg OR restaurants where all items are veg)
        if vegOnly {
            results = results.filter { $0.isPureVeg || $0.menuItems.allSatisfy { $0.isVeg } }
        }
        
        // Rating filter
        if rating4Plus {
            results = results.filter { $0.rating >= 4.0 }
        }
        
        // Open filter
        if openOnly {
            results = results.filter { $0.isOpen }
        }
        
        // Price filter (price for two <= 300)
        if under200 {
            results = results.filter { $0.priceForTwo <= 300 }
        }
        
        // Near & Fast filter
        if nearFast {
            results = results.filter {
                let distStr = $0.distance.replacingOccurrences(of: " km", with: "").trimmingCharacters(in: .whitespaces)
                let distNum = Double(distStr) ?? 99.0
                return distNum <= 2.5
            }
        }
        
        // Has Offers filter
        if hasOffers {
            results = results.filter { $0.offer != nil && !($0.offer?.isEmpty ?? true) }
        }
        
        // Search
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.cuisineText.lowercased().contains(query) ||
                $0.categories.contains(where: { $0.rawValue.lowercased().contains(query) }) ||
                $0.menuItems.contains(where: { $0.name.lowercased().contains(query) })
            }
        }
        
        // Sort
        switch sortBy {
        case .relevance:
            break // keep default order
        case .ratingHighToLow:
            results.sort { $0.rating > $1.rating }
        case .deliveryTime:
            results.sort {
                let t1 = Int($0.deliveryTime.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 99
                let t2 = Int($1.deliveryTime.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 99
                return t1 < t2
            }
        case .costLowToHigh:
            results.sort { $0.priceForTwo < $1.priceForTwo }
        case .costHighToLow:
            results.sort { $0.priceForTwo > $1.priceForTwo }
        case .distance:
            results.sort {
                let d1 = Double($0.distance.replacingOccurrences(of: " km", with: "").trimmingCharacters(in: .whitespaces)) ?? 99.0
                let d2 = Double($1.distance.replacingOccurrences(of: " km", with: "").trimmingCharacters(in: .whitespaces)) ?? 99.0
                return d1 < d2
            }
        }
        
        return results
    }
    
    // MARK: - Search
    
    public func searchAll(query: String) -> (restaurants: [Restaurant], dishes: [MenuItem], cuisines: [ZomatoCategory]) {
        let q = query.lowercased()
        
        let restaurants = allRestaurants.filter {
            $0.name.lowercased().contains(q) || $0.cuisineText.lowercased().contains(q)
        }
        
        var dishes: [MenuItem] = []
        for r in allRestaurants {
            for item in r.menuItems where item.name.lowercased().contains(q) || (item.description?.lowercased().contains(q) ?? false) {
                if !dishes.contains(where: { $0.id == item.id }) {
                    dishes.append(item)
                }
            }
        }
        
        let cuisines = ZomatoCategory.allCases.filter { $0.rawValue.lowercased().contains(q) && $0 != .all }
        
        return (restaurants, dishes, cuisines)
    }
    
    public func restaurant(for id: String) -> Restaurant? {
        allRestaurants.first(where: { $0.id == id })
    }
    
    // MARK: - Featured & Recommended
    
    public var featuredRestaurants: [Restaurant] {
        allRestaurants.filter { $0.isFeatured }
    }
    
    public var sponsoredRestaurants: [Restaurant] {
        allRestaurants.filter { $0.isSponsored }
    }
    
    public var restaurantsWithOffers: [Restaurant] {
        allRestaurants.filter { $0.offer != nil }.prefix(6).map { $0 }
    }
    
    public var topRatedRestaurants: [Restaurant] {
        allRestaurants.sorted { $0.rating > $1.rating }.prefix(6).map { $0 }
    }
}

public enum SortOption: String, CaseIterable, Identifiable {
    case relevance = "Relevance"
    case ratingHighToLow = "Rating"
    case deliveryTime = "Delivery Time"
    case costLowToHigh = "Cost: Low to High"
    case costHighToLow = "Cost: High to Low"
    case distance = "Distance"
    
    public var id: String { rawValue }
}
