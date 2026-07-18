//
//  GroupCart.swift
//  BlinkitFlow
//

import Foundation

public struct GroupCart: Identifiable, Codable, Hashable {
    public let id: String
    public let code: String
    public var title: String
    public var participants: [User]
    public var items: [CartItem]
    public var isActive: Bool
    
    public init(
        id: String = UUID().uuidString,
        code: String = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! }),
        title: String = "Weekend Party Grocery",
        participants: [User] = [],
        items: [CartItem] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.code = code
        self.title = title
        self.participants = participants
        self.items = items
        self.isActive = isActive
    }
}
