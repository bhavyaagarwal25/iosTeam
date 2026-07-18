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
        name: "You",
        avatarName: "person.crop.circle.fill",
        isCurrentUser: true,
        colorHex: "0C831F"
    )
    
    public static let userRahul = User(
        id: "usr_2",
        name: "Rahul",
        avatarName: "person.fill",
        isCurrentUser: false,
        colorHex: "007AFF"
    )
    
    public static let userPriya = User(
        id: "usr_3",
        name: "Priya",
        avatarName: "person.fill.turn.down",
        isCurrentUser: false,
        colorHex: "FF2D55"
    )
    
    public static let allUsers: [User] = [currentUser, userRahul, userPriya]
    
    // 25 Realistic Indian Grocery Products
    public static let sampleProducts: [Product] = [
        // Dairy & Bread
        Product(
            id: "p1",
            name: "Amul Taaza Toned Fresh Milk",
            category: .dairy,
            price: 28.0,
            discountPrice: 27.0,
            unit: "500 ml",
            systemImage: "drop.fill",
            rating: 4.9,
            deliveryTime: "8 mins",
            description: "Pasteurised toned milk with essential vitamins. Freshly sourced daily.",
            isPopular: true,
            tag: "Bestseller"
        ),
        Product(
            id: "p2",
            name: "Amul Salted Butter",
            category: .dairy,
            price: 58.0,
            discountPrice: 56.0,
            unit: "100 g",
            systemImage: "square.fill",
            rating: 4.8,
            deliveryTime: "8 mins",
            description: "Pure butter made from wholesome cow and buffalo milk.",
            isPopular: true,
            tag: "Popular"
        ),
        Product(
            id: "p3",
            name: "Britannia 100% Whole Wheat Bread",
            category: .dairy,
            price: 50.0,
            discountPrice: 45.0,
            unit: "400 g",
            systemImage: "square.grid.3x3.fill",
            rating: 4.7,
            deliveryTime: "9 mins",
            description: "Soft and nutritious 100% whole wheat bread packed with fiber.",
            isPopular: true
        ),
        Product(
            id: "p4",
            name: "Epigamia Natural Greek Yogurt",
            category: .dairy,
            price: 60.0,
            discountPrice: 52.0,
            unit: "100 g",
            systemImage: "cup.and.saucer",
            rating: 4.6,
            deliveryTime: "10 mins",
            description: "High protein, thick and creamy natural Greek yogurt.",
            isPopular: false
        ),
        Product(
            id: "p5",
            name: "Mother Dairy Paneer (Cottage Cheese)",
            category: .dairy,
            price: 110.0,
            discountPrice: 99.0,
            unit: "200 g",
            systemImage: "cube.fill",
            rating: 4.8,
            deliveryTime: "8 mins",
            description: "Soft, fresh, hygienic cottage cheese rich in calcium and protein.",
            isPopular: true,
            tag: "Fresh"
        ),
        
        // Fruits & Veg
        Product(
            id: "p6",
            name: "Hybrid Tomato (Tamatar)",
            category: .fruitsVeg,
            price: 40.0,
            discountPrice: 32.0,
            unit: "1 kg",
            systemImage: "globe.americas.fill",
            rating: 4.7,
            deliveryTime: "8 mins",
            description: "Farm-fresh ripe red tomatoes packed with lycopene and vitamin C.",
            isPopular: true,
            tag: "20% OFF"
        ),
        Product(
            id: "p7",
            name: "Fresh Red Onion (Pyaz)",
            category: .fruitsVeg,
            price: 35.0,
            discountPrice: 29.0,
            unit: "1 kg",
            systemImage: "circle.fill",
            rating: 4.6,
            deliveryTime: "8 mins",
            description: "Premium quality crunchy Indian red onions direct from farmers.",
            isPopular: true
        ),
        Product(
            id: "p8",
            name: "Fresh Potato (Aloo)",
            category: .fruitsVeg,
            price: 30.0,
            discountPrice: 26.0,
            unit: "1 kg",
            systemImage: "oval.fill",
            rating: 4.5,
            deliveryTime: "8 mins",
            description: "Versatile, fresh farm potatoes ideal for cooking and frying.",
            isPopular: true
        ),
        Product(
            id: "p9",
            name: "Robusta Banana",
            category: .fruitsVeg,
            price: 45.0,
            discountPrice: 39.0,
            unit: "6 pcs",
            systemImage: "leaf.fill",
            rating: 4.8,
            deliveryTime: "10 mins",
            description: "Naturally ripened sweet Robusta bananas rich in potassium.",
            isPopular: false
        ),
        Product(
            id: "p10",
            name: "Washington Red Delicious Apple",
            category: .fruitsVeg,
            price: 180.0,
            discountPrice: 155.0,
            unit: "4 pcs (~700g)",
            systemImage: "applelogo",
            rating: 4.9,
            deliveryTime: "10 mins",
            description: "Crisp, juicy and extra sweet imported red apples.",
            isPopular: true,
            tag: "Imported"
        ),
        
        // Snacks & Munchies
        Product(
            id: "p11",
            name: "Maggi 2-Minute Masala Noodles",
            category: .snacks,
            price: 96.0,
            discountPrice: 88.0,
            unit: "Pack of 12 (560g)",
            systemImage: "internaldrive.fill",
            rating: 4.9,
            deliveryTime: "8 mins",
            description: "India's favorite instant noodles infused with signature roasted spices.",
            isPopular: true,
            tag: "Iconic"
        ),
        Product(
            id: "p12",
            name: "Lay's India's Magic Masala Chips",
            category: .snacks,
            price: 20.0,
            discountPrice: 20.0,
            unit: "50 g",
            systemImage: "circle.grid.cross.fill",
            rating: 4.8,
            deliveryTime: "8 mins",
            description: "Crispy potato chips seasoned with Indian spices and herbs.",
            isPopular: true
        ),
        Product(
            id: "p13",
            name: "Haldiram's Nagpur Aloo Bhujia",
            category: .snacks,
            price: 65.0,
            discountPrice: 59.0,
            unit: "200 g",
            systemImage: "flame.fill",
            rating: 4.7,
            deliveryTime: "9 mins",
            description: "Crispy potato mint snack sprinkled with savory spices.",
            isPopular: true
        ),
        Product(
            id: "p14",
            name: "Doritos Nacho Cheese Tortilla Chips",
            category: .snacks,
            price: 50.0,
            discountPrice: 45.0,
            unit: "82.5 g",
            systemImage: "triangle.fill",
            rating: 4.6,
            deliveryTime: "9 mins",
            description: "Crunchy corn tortilla chips coated with melted cheddar cheese flavor.",
            isPopular: false
        ),
        Product(
            id: "p15",
            name: "Cadbury Dairy Milk Silk Chocolate",
            category: .snacks,
            price: 175.0,
            discountPrice: 159.0,
            unit: "150 g",
            systemImage: "heart.fill",
            rating: 4.9,
            deliveryTime: "8 mins",
            description: "Richer, smoother and creamier milk chocolate bar.",
            isPopular: true,
            tag: "Indulgence"
        ),
        
        // Cold Drinks & Juices
        Product(
            id: "p16",
            name: "Coca-Cola Original Soft Drink",
            category: .beverages,
            price: 40.0,
            discountPrice: 38.0,
            unit: "750 ml",
            systemImage: "bubbles.and.sparkles.fill",
            rating: 4.8,
            deliveryTime: "8 mins",
            description: "Crisp, refreshing carbonated beverage best served chilled.",
            isPopular: true
        ),
        Product(
            id: "p17",
            name: "Real Fruit Power Alphonso Mango Juice",
            category: .beverages,
            price: 125.0,
            discountPrice: 110.0,
            unit: "1 L",
            systemImage: "sun.max.fill",
            rating: 4.7,
            deliveryTime: "9 mins",
            description: "Delicious rich mango nectar made from handpicked Alphonso mangoes.",
            isPopular: true
        ),
        Product(
            id: "p18",
            name: "Red Bull Energy Drink",
            category: .beverages,
            price: 125.0,
            discountPrice: 120.0,
            unit: "250 ml",
            systemImage: "bolt.fill",
            rating: 4.8,
            deliveryTime: "8 mins",
            description: "Vitalizes body and mind with taurine, caffeine and vitamins.",
            isPopular: true,
            tag: "Boost"
        ),
        Product(
            id: "p19",
            name: "Bisleri Packaged Drinking Water",
            category: .beverages,
            price: 20.0,
            discountPrice: 20.0,
            unit: "1 L",
            systemImage: "drop.circle.fill",
            rating: 4.9,
            deliveryTime: "7 mins",
            description: "Pure, safe, ozonated mineralized drinking water.",
            isPopular: true
        ),
        
        // Household Essentials
        Product(
            id: "p20",
            name: "Surf Excel Easy Wash Detergent Powder",
            category: .household,
            price: 140.0,
            discountPrice: 125.0,
            unit: "1 kg",
            systemImage: "washer.fill",
            rating: 4.8,
            deliveryTime: "10 mins",
            description: "Removes tough stains inside the washing machine or handwash.",
            isPopular: false
        ),
        Product(
            id: "p21",
            name: "Vim Dishwash Gel Lemon",
            category: .household,
            price: 115.0,
            discountPrice: 99.0,
            unit: "500 ml",
            systemImage: "sparkles",
            rating: 4.9,
            deliveryTime: "9 mins",
            description: "1 spoon of Vim Gel cleans a sink full of oily utensils.",
            isPopular: true
        ),
        Product(
            id: "p22",
            name: "Dettol Antiseptic Disinfectant Liquid",
            category: .household,
            price: 215.0,
            discountPrice: 195.0,
            unit: "550 ml",
            systemImage: "shield.checkerboard",
            rating: 4.9,
            deliveryTime: "10 mins",
            description: "Provides protection against germs across laundry, floor & personal hygiene.",
            isPopular: false
        ),
        Product(
            id: "p23",
            name: "Fortune Sunlite Refined Sunflower Oil",
            category: .household,
            price: 145.0,
            discountPrice: 132.0,
            unit: "1 L Pouch",
            systemImage: "cylinder.fill",
            rating: 4.7,
            deliveryTime: "9 mins",
            description: "Light, healthy, refined sunflower oil enriched with Vitamin E.",
            isPopular: true
        ),
        Product(
            id: "p24",
            name: "Tata Salt Vacuum Evaporated Iodised Salt",
            category: .household,
            price: 28.0,
            discountPrice: 25.0,
            unit: "1 kg",
            systemImage: "snow",
            rating: 4.9,
            deliveryTime: "8 mins",
            description: "India's Desh Ka Namak with guaranteed purity and iodine balance.",
            isPopular: true
        ),
        Product(
            id: "p25",
            name: "Aashirvaad Shuddh Chakki Atta",
            category: .household,
            price: 260.0,
            discountPrice: 235.0,
            unit: "5 kg",
            systemImage: "archivebox.fill",
            rating: 4.9,
            deliveryTime: "10 mins",
            description: "100% pure whole wheat flour ground in traditional stone chakki.",
            isPopular: true,
            tag: "Value Pack"
        )
    ]
    
    // Saved Lists for 1-Tap Reorder
    public static let savedLists: [SavedList] = [
        SavedList(
            id: "sl_1",
            title: "Daily Morning Essentials",
            subtitle: "Milk, Bread, Butter & Eggs",
            iconName: "sun.max.fill",
            products: [sampleProducts[0], sampleProducts[1], sampleProducts[2]]
        ),
        SavedList(
            id: "sl_2",
            title: "Friday Movie Night Snacks",
            subtitle: "Maggi, Lay's & Coke",
            iconName: "tv.fill",
            products: [sampleProducts[10], sampleProducts[11], sampleProducts[15]]
        ),
        SavedList(
            id: "sl_3",
            title: "Weekly Veggie Staples",
            subtitle: "Tomato, Onion & Potato",
            iconName: "leaf.fill",
            products: [sampleProducts[5], sampleProducts[6], sampleProducts[7]]
        )
    ]
    
    // Initial Past Orders
    public static let mockPastOrders: [Order] = [
        Order(
            id: "BLK-892104",
            items: [
                CartItem(product: sampleProducts[0], quantity: 2, addedBy: currentUser),
                CartItem(product: sampleProducts[2], quantity: 1, addedBy: currentUser),
                CartItem(product: sampleProducts[10], quantity: 1, addedBy: currentUser)
            ],
            totalAmount: 199.0,
            stage: .delivered,
            orderDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            estimatedDeliveryMinutes: 0,
            riderName: "Sunil Verma",
            riderPhone: "+91 91234 56789",
            deliveryAddress: "Flat 402, Sunshine Heights, Bengaluru",
            paymentMethod: "Blinkit Pay (UPI)"
        ),
        Order(
            id: "BLK-771490",
            items: [
                CartItem(product: sampleProducts[5], quantity: 1, addedBy: currentUser),
                CartItem(product: sampleProducts[6], quantity: 1, addedBy: currentUser),
                CartItem(product: sampleProducts[23], quantity: 1, addedBy: currentUser)
            ],
            totalAmount: 86.0,
            stage: .delivered,
            orderDate: Date().addingTimeInterval(-86400 * 5), // 5 days ago
            estimatedDeliveryMinutes: 0,
            riderName: "Vikram Singh",
            riderPhone: "+91 98888 77777",
            deliveryAddress: "Flat 402, Sunshine Heights, Bengaluru",
            paymentMethod: "Google Pay"
        )
    ]
}
