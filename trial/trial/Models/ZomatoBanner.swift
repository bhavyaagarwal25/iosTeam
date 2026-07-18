//
//  ZomatoBanner.swift
//  trial
//

import Foundation
import SwiftUI

public struct ZomatoBanner: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let imageName: String
    public let gradientColors: [Color]
    public let badgeText: String?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        imageName: String = "pizza",
        gradientColors: [Color] = [.red, .orange],
        badgeText: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.gradientColors = gradientColors
        self.badgeText = badgeText
    }
}
