//
//  MockData.swift
//  BlinkitFlow
//

import Foundation

public struct SavedList: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let products: [Product]
}

public enum MockData {
    // Mock Users
    public static let currentUser = User(
        id: "usr_1",
        name: "you",
        avatarName: "person.crop.circle.fill",
        isCurrentUser: true,
        colorHex: "0C831F"
    )
    
    public static let userRahul = User(
        id: "usr_2",
        name: "rahul",
        avatarName: "person.fill",
        isCurrentUser: false,
        colorHex: "007AFF"
    )
    
    public static let userPriya = User(
        id: "usr_3",
        name: "priya",
        avatarName: "person.fill.turn.down",
        isCurrentUser: false,
        colorHex: "FF2D55"
    )
    
    public static let allUsers: [User] = [currentUser, userRahul, userPriya]
    
    // Products — only those with matching asset images ({name}_product)
    public static let sampleProducts: [Product] = [
        // 0: milk
        Product(id: "p1", name: "milk", category: .dairy, price: 28.0, discountPrice: 27.0, unit: "500 ml", systemImage: "drop.fill", rating: 4.9, deliveryTime: "8 mins", description: "Fresh toned milk.", isPopular: true, tag: "Bestseller"),
        // 1: butter
        Product(id: "p2", name: "butter", category: .dairy, price: 58.0, discountPrice: 56.0, unit: "100 g", systemImage: "square.fill", rating: 4.8, deliveryTime: "8 mins", description: "Pure butter.", isPopular: true, tag: "Popular"),
        // 2: bread
        Product(id: "p3", name: "bread", category: .dairy, price: 50.0, discountPrice: 45.0, unit: "400 g", systemImage: "square.split.3x3.fill", rating: 4.7, deliveryTime: "9 mins", description: "Whole wheat bread.", isPopular: true),
        // 3: cheese
        Product(id: "p5", name: "cheese", category: .dairy, price: 110.0, discountPrice: 99.0, unit: "200 g", systemImage: "cube.fill", rating: 4.8, deliveryTime: "8 mins", description: "Fresh cottage cheese.", isPopular: true, tag: "Fresh"),
        // 4: icecream
        Product(id: "p101", name: "icecream", category: .dairy, price: 150.0, discountPrice: 120.0, unit: "500 ml", systemImage: "snowflake", rating: 4.9, deliveryTime: "8 mins", description: "Vanilla icecream.", isPopular: true, tag: "Best Seller"),
        // 5: dahi
        Product(id: "p105", name: "dahi", category: .dairy, price: 45.0, discountPrice: 40.0, unit: "400 g", systemImage: "cup.and.saucer.fill", rating: 4.9, deliveryTime: "8 mins", description: "Fresh dahi.", isPopular: true, tag: "Fresh"),
        // 6: eggs
        Product(id: "p10", name: "eggs", category: .dairy, price: 60.0, discountPrice: 55.0, unit: "6 pcs", systemImage: "circle.grid.2x2.fill", rating: 4.9, deliveryTime: "8 mins", description: "Farm fresh eggs.", isPopular: true, tag: "High Protein"),
        // 7: fruits
        Product(id: "p102", name: "fruits", category: .fruitsVeg, price: 120.0, discountPrice: 99.0, unit: "1 kg", systemImage: "applelogo", rating: 4.8, deliveryTime: "8 mins", description: "Seasonal fruits.", isPopular: true),
        // 8: vegetables
        Product(id: "p103", name: "vegetables", category: .fruitsVeg, price: 80.0, discountPrice: 65.0, unit: "1 kg", systemImage: "carrot.fill", rating: 4.7, deliveryTime: "8 mins", description: "Mixed vegetables.", isPopular: true),
        // 9: tomato
        Product(id: "p6", name: "tomato", category: .fruitsVeg, price: 40.0, discountPrice: 32.0, unit: "1 kg", systemImage: "globe.americas.fill", rating: 4.7, deliveryTime: "8 mins", description: "Ripe red tomatoes.", isPopular: true, tag: "20% OFF"),
        // 10: potato
        Product(id: "p8", name: "potato", category: .fruitsVeg, price: 30.0, discountPrice: 26.0, unit: "1 kg", systemImage: "oval.fill", rating: 4.5, deliveryTime: "8 mins", description: "Fresh farm potatoes.", isPopular: true),
        // 11: maggi
        Product(id: "p11", name: "maggi", category: .snacks, price: 96.0, discountPrice: 88.0, unit: "Pack of 12", systemImage: "internaldrive.fill", rating: 4.9, deliveryTime: "8 mins", description: "Instant noodles.", isPopular: true, tag: "Iconic"),
        // 12: lays
        Product(id: "p12", name: "lays", category: .snacks, price: 20.0, discountPrice: 20.0, unit: "50 g", systemImage: "circle.grid.cross.fill", rating: 4.8, deliveryTime: "8 mins", description: "Potato chips.", isPopular: true),
        // 13: aloo (bhujia)
        Product(id: "p13", name: "aloo", category: .snacks, price: 65.0, discountPrice: 59.0, unit: "200 g", systemImage: "flame.fill", rating: 4.7, deliveryTime: "9 mins", description: "Aloo bhujia.", isPopular: true),
        // 14: cadbury
        Product(id: "p15", name: "cadbury", category: .snacks, price: 175.0, discountPrice: 159.0, unit: "150 g", systemImage: "heart.fill", rating: 4.9, deliveryTime: "8 mins", description: "Silk chocolate.", isPopular: true, tag: "Indulgence"),
        // 15: sauce
        Product(id: "p104", name: "sauce", category: .snacks, price: 90.0, discountPrice: 85.0, unit: "500 g", systemImage: "drop.triangle.fill", rating: 4.6, deliveryTime: "8 mins", description: "Tomato sauce.", isPopular: false),
        // 16: coca
        Product(id: "p16", name: "coca", category: .beverages, price: 40.0, discountPrice: 38.0, unit: "750 ml", systemImage: "bubbles.and.sparkles.fill", rating: 4.8, deliveryTime: "8 mins", description: "Coca-Cola.", isPopular: true),
        // 17: real (mango juice)
        Product(id: "p17", name: "real", category: .beverages, price: 125.0, discountPrice: 110.0, unit: "1 L", systemImage: "sun.max.fill", rating: 4.7, deliveryTime: "9 mins", description: "Mango juice.", isPopular: true),
        // 18: red (bull)
        Product(id: "p18", name: "red", category: .beverages, price: 125.0, discountPrice: 120.0, unit: "250 ml", systemImage: "bolt.fill", rating: 4.8, deliveryTime: "8 mins", description: "Red Bull.", isPopular: true, tag: "Boost"),
        // 19: bisleri
        Product(id: "p19", name: "bisleri", category: .beverages, price: 20.0, discountPrice: 20.0, unit: "1 L", systemImage: "drop.circle.fill", rating: 4.9, deliveryTime: "7 mins", description: "Packaged water.", isPopular: true),
        // 20: vim
        Product(id: "p21", name: "vim", category: .household, price: 115.0, discountPrice: 99.0, unit: "500 ml", systemImage: "sparkles", rating: 4.9, deliveryTime: "9 mins", description: "Dishwash gel.", isPopular: true),
        // 21: dettol
        Product(id: "p22", name: "dettol", category: .household, price: 215.0, discountPrice: 195.0, unit: "550 ml", systemImage: "shield.checkerboard", rating: 4.9, deliveryTime: "10 mins", description: "Antiseptic liquid.", isPopular: false),
        // 22: fortune
        Product(id: "p23", name: "fortune", category: .household, price: 145.0, discountPrice: 132.0, unit: "1 L", systemImage: "cylinder.fill", rating: 4.7, deliveryTime: "9 mins", description: "Sunflower oil.", isPopular: true),
        // 23: tata (salt)
        Product(id: "p24", name: "tata", category: .household, price: 28.0, discountPrice: 25.0, unit: "1 kg", systemImage: "snow", rating: 4.9, deliveryTime: "8 mins", description: "Iodised salt.", isPopular: true)
    ]
    
    // Saved Lists for 1-Tap Reorder
    public static let savedLists: [SavedList] = [
        SavedList(
            id: "sl_1",
            title: "Morning Essentials",
            subtitle: "Milk, Bread, Butter & Eggs",
            iconName: "sun.max.fill",
            products: [sampleProducts[0], sampleProducts[1], sampleProducts[2]]
        ),
        SavedList(
            id: "sl_2",
            title: "Movie Night Snacks",
            subtitle: "Maggi, Lays & Coke",
            iconName: "tv.fill",
            products: [sampleProducts[11], sampleProducts[12], sampleProducts[16]]
        ),
        SavedList(
            id: "sl_3",
            title: "Weekly Veggies",
            subtitle: "Tomato, Potato & Vegetables",
            iconName: "leaf.fill",
            products: [sampleProducts[9], sampleProducts[10], sampleProducts[8]]
        )
    ]
    
    // Initial Past Orders
    public static let mockPastOrders: [Order] = [
        Order(
            id: "BLK-892104",
            items: [
                CartItem(product: sampleProducts[0], quantity: 2, addedBy: currentUser),
                CartItem(product: sampleProducts[2], quantity: 1, addedBy: currentUser),
                CartItem(product: sampleProducts[11], quantity: 1, addedBy: currentUser)
            ],
            totalAmount: 199.0,
            stage: .delivered,
            orderDate: Date().addingTimeInterval(-86400 * 2),
            estimatedDeliveryMinutes: 0,
            riderName: "Sunil Verma",
            riderPhone: "+91 91234 56789",
            deliveryAddress: "Flat 402, Sunshine Heights, Bengaluru",
            paymentMethod: "Blinkit Pay (UPI)"
        ),
        Order(
            id: "BLK-771490",
            items: [
                CartItem(product: sampleProducts[9], quantity: 1, addedBy: currentUser),
                CartItem(product: sampleProducts[10], quantity: 1, addedBy: currentUser),
                CartItem(product: sampleProducts[23], quantity: 1, addedBy: currentUser)
            ],
            totalAmount: 86.0,
            stage: .delivered,
            orderDate: Date().addingTimeInterval(-86400 * 5),
            estimatedDeliveryMinutes: 0,
            riderName: "Vikram Singh",
            riderPhone: "+91 98888 77777",
            deliveryAddress: "Flat 402, Sunshine Heights, Bengaluru",
            paymentMethod: "Google Pay"
        )
    ]
}
