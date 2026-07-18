//
//  ZomatoSearchView.swift
//  trial
//

import SwiftUI

public struct ZomatoSearchView: View {
    @StateObject private var viewModel = ZomatoSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search for restaurants, dishes...", text: $viewModel.searchQuery)
                            .font(.system(size: 16))
                            .focused($isSearchFocused)
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.clearSearch() }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12).background(Color.gray.opacity(0.08)).cornerRadius(12)
                    
                    Button("Cancel") { dismiss() }.foregroundColor(.red).font(.system(size: 15))
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                
                ScrollView(showsIndicators: false) {
                    if viewModel.searchQuery.isEmpty {
                        emptyStateView
                    } else if viewModel.hasResults {
                        resultsView
                    } else {
                        noResultsView
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { isSearchFocused = true }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recent
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Searches").font(.system(size: 16, weight: .bold))
                        Spacer()
                        Button("Clear") { viewModel.clearRecent() }.font(.system(size: 13)).foregroundColor(.red)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { term in
                                Button(action: { viewModel.selectSearch(term) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock.arrow.circlepath").font(.system(size: 12))
                                        Text(term).font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.08)).cornerRadius(20)
                                }
                            }
                        }
                    }
                }
            }
            
            // Trending
            VStack(alignment: .leading, spacing: 12) {
                Text("Trending Searches 🔥").font(.system(size: 16, weight: .bold))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.trendingSearches, id: \.self) { term in
                            Button(action: { viewModel.selectSearch(term) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right").font(.system(size: 10)).foregroundColor(.red)
                                    Text(term).font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Color.red.opacity(0.05)).cornerRadius(20)
                            }
                        }
                    }
                }
            }
            
            // Quick cuisine links
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Cuisines").font(.system(size: 16, weight: .bold))
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach([ZomatoCategory.pizza, .burger, .chinese, .biryani, .southIndian, .italian, .rolls, .desserts]) { cat in
                        Button(action: { viewModel.selectSearch(cat.rawValue) }) {
                            VStack(spacing: 6) {
                                Text(cat.iconName).font(.system(size: 28))
                                Text(cat.rawValue).font(.system(size: 12, weight: .medium))
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color.gray.opacity(0.05)).cornerRadius(12)
                        }.foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 8)
    }
    
    // MARK: - Results
    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cuisine results
            if !viewModel.cuisineResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cuisines").font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                    ForEach(viewModel.cuisineResults) { cuisine in
                        HStack {
                            Text(cuisine.iconName).font(.system(size: 24))
                            Text(cuisine.rawValue).font(.system(size: 16, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                Divider()
            }
            
            // Dish results
            if !viewModel.dishResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dishes").font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                    ForEach(viewModel.dishResults.prefix(8)) { dish in
                        HStack(spacing: 12) {
                            Image(dish.imageName).resizable().aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50).cornerRadius(8).clipped()
                            VStack(alignment: .leading, spacing: 3) {
                                Text(dish.name).font(.system(size: 15, weight: .medium))
                                Text("₹\(Int(dish.price))").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                Divider()
            }
            
            // Restaurant results
            if !viewModel.restaurantResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Restaurants").font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                    ForEach(viewModel.restaurantResults) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            HStack(spacing: 12) {
                                Image(restaurant.imageName).resizable().aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60).cornerRadius(10).clipped()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(restaurant.name).font(.system(size: 16, weight: .bold))
                                    Text(restaurant.cuisineText).font(.system(size: 13)).foregroundColor(.secondary).lineLimit(1)
                                    HStack(spacing: 6) {
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 10))
                                            Text(String(format: "%.1f", restaurant.rating)).font(.system(size: 12, weight: .medium))
                                        }
                                        Text("•")
                                        Text(restaurant.deliveryTime).font(.system(size: 12))
                                    }.foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 8)
    }
    
    // MARK: - No Results
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass").font(.system(size: 50)).foregroundColor(.gray.opacity(0.4))
            Text("No results found").font(.system(size: 18, weight: .bold))
            Text("Try searching for a restaurant, cuisine, or dish")
                .font(.system(size: 14)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.top, 80)
    }
}


