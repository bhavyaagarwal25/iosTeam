//
//  ZomatoOffer.swift
//  trial
//

import Foundation

public struct ZomatoOffer: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let restaurantId: String?
    public let discountText: String
    public let iconName: String
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        restaurantId: String? = nil,
        discountText: String,
        iconName: String = "tag.fill"
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.restaurantId = restaurantId
        self.discountText = discountText
        self.iconName = iconName
    }
}
