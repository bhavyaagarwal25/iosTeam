//
//  ZomatoSearchViewModel.swift
//  trial
//

import Foundation
import Combine
import UIKit

@MainActor
public class ZomatoSearchViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var restaurantResults: [Restaurant] = []
    @Published public var dishResults: [MenuItem] = []
    @Published public var cuisineResults: [ZomatoCategory] = []
    @Published public var recentSearches: [String] = ["Pizza", "Biryani", "Burger", "Chinese", "Coffee"]
    @Published public var isSearching: Bool = false
    
    public let trendingSearches: [String] = ["Butter Chicken", "Margherita Pizza", "Masala Dosa", "Hakka Noodles", "Paneer Tikka", "Momos", "Brownie", "Cold Coffee"]
    
    private let dataService = ZomatoDataService.shared
    private var searchCancellable: AnyCancellable?
    
    public init() {
        // Debounced search
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
    }
    
    public func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            restaurantResults = []
            dishResults = []
            cuisineResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        let results = dataService.searchAll(query: query)
        restaurantResults = results.restaurants
        dishResults = results.dishes
        cuisineResults = results.cuisines
        isSearching = false
    }
    
    public func selectSearch(_ term: String) {
        searchQuery = term
        if !recentSearches.contains(term) {
            recentSearches.insert(term, at: 0)
            if recentSearches.count > 8 {
                recentSearches.removeLast()
            }
        }
    }
    
    public func clearRecent() {
        recentSearches.removeAll()
    }
    
    public func clearSearch() {
        searchQuery = ""
        restaurantResults = []
        dishResults = []
        cuisineResults = []
    }
    
    public var hasResults: Bool {
        !restaurantResults.isEmpty || !dishResults.isEmpty || !cuisineResults.isEmpty
    }
}
