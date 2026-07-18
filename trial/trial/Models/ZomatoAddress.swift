//
//  ZomatoAddress.swift
//  trial
//

import Foundation

public struct ZomatoAddress: Identifiable, Codable, Hashable {
    public let id: String
    public let label: String // "Home", "Work", "Other"
    public let fullAddress: String
    public let landmark: String
    public let isDefault: Bool
    public let iconName: String
    
    public init(
        id: String = UUID().uuidString,
        label: String,
        fullAddress: String,
        landmark: String = "",
        isDefault: Bool = false,
        iconName: String = "mappin.circle.fill"
    ) {
        self.id = id
        self.label = label
        self.fullAddress = fullAddress
        self.landmark = landmark
        self.isDefault = isDefault
        self.iconName = iconName
    }
}
