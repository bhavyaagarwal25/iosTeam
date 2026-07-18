//
//  BlinkitTheme.swift
//  BlinkitFlow
//
//  Created for Blinkit Flow Hackathon Project.
//

import SwiftUI
import UIKit

public enum BlinkitTheme {
    // Brand Colors
    public static let yellow = Color(hex: "F4C430")
    public static let yellowDark = Color(hex: "E0B020")
    public static let brandGreen = Color(hex: "0C831F")
    public static let brandGreenLight = Color(hex: "E7F6EB")
    public static let darkBackground = Color(hex: "121212")
    public static let cardBackground = Color(hex: "1E1E1E")
    public static let lightCardBackground = Color(hex: "F8F9FA")
    public static let textPrimaryDark = Color.white
    public static let textSecondaryDark = Color(hex: "AAAAAA")
    public static let textPrimaryLight = Color(hex: "1C1C1E")
    public static let textSecondaryLight = Color(hex: "6C757D")
    
    // Haptic Feedback Helper
    public static func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func triggerNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
