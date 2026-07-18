//
//  User.swift
//  BlinkitFlow
//

import Foundation

public struct User: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let avatarName: String
    public let isCurrentUser: Bool
    public let colorHex: String
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        avatarName: String = "person.crop.circle.fill",
        isCurrentUser: Bool = false,
        colorHex: String = "0C831F"
    ) {
        self.id = id
        self.name = name
        self.avatarName = avatarName
        self.isCurrentUser = isCurrentUser
        self.colorHex = colorHex
    }
}
