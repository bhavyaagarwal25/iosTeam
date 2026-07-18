//
//  ContextEngineService.swift
//  BlinkitFlow
//

import Foundation

public struct ContextInfo {
    public let greetingTitle: String
    public let greetingSubtitle: String
    public let suggestedCategories: [ProductCategory]
    public let bannerIcon: String
    public let recommendedProducts: [Product]
}

public class ContextEngineService {
    public static let shared = ContextEngineService()
    
    public init() {}
    
    public func getCurrentContext(overrideHour: Int? = nil) -> ContextInfo {
        let hour = overrideHour ?? Calendar.current.component(.hour, from: Date())
        let products = MockData.sampleProducts
        
        switch hour {
        case 5..<12:
            // Morning
            let morningRecs = products.filter { $0.category == .dairy || $0.category == .fruitsVeg }
            return ContextInfo(
                greetingTitle: "Good Morning! ☕",
                greetingSubtitle: "Fresh milk, bread & breakfast staples in 8 mins",
                suggestedCategories: [.dairy, .fruitsVeg, .beverages],
                bannerIcon: "sun.max.fill",
                recommendedProducts: Array(morningRecs.prefix(6))
            )
        case 12..<17:
            // Afternoon
            let afternoonRecs = products.filter { $0.category == .beverages || $0.category == .household }
            return ContextInfo(
                greetingTitle: "Afternoon Refreshments 🍹",
                greetingSubtitle: "Cool drinks, juices & lunch essentials ready to deliver",
                suggestedCategories: [.beverages, .snacks, .household],
                bannerIcon: "sun.haze.fill",
                recommendedProducts: Array(afternoonRecs.prefix(6))
            )
        case 17..<22:
            // Evening
            let eveningRecs = products.filter { $0.category == .snacks || $0.category == .beverages }
            return ContextInfo(
                greetingTitle: "Evening Cravings? 🍿",
                greetingSubtitle: "Maggi, chips, sodas & tea-time snacks delivered fast",
                suggestedCategories: [.snacks, .beverages, .dairy],
                bannerIcon: "popcorn.fill",
                recommendedProducts: Array(eveningRecs.prefix(6))
            )
        default:
            // Night
            let nightRecs = products.filter { $0.category == .snacks || $0.category == .beverages }
            return ContextInfo(
                greetingTitle: "Good Evening! 🌙",
                greetingSubtitle: "Late night cravings delivered fast",
                suggestedCategories: [.snacks, .beverages],
                bannerIcon: "moon.stars.fill",
                recommendedProducts: Array(nightRecs.prefix(6))
            )
        }
    }
}
