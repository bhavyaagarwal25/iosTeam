//
//  MockZomatoData.swift
//  trial
//
//  25 Restaurants with 150+ Menu Items — Realistic Indian food delivery data
//

import Foundation
import SwiftUI

public struct MockZomatoData {
    
    // MARK: - Food Images (cycle through available assets)
    private static let foodImages = ["pizza", "burger", "paratha", "chillWithCheese"]
    static func img(_ index: Int) -> String { foodImages[index % foodImages.count] }
    
    // MARK: - Pizza Customizations
    static let pizzaCustomizations: [CustomizationGroup] = [
        CustomizationGroup(name: "Size", options: [
            CustomizationOption(name: "Regular (7\")", price: 0, isSelected: true),
            CustomizationOption(name: "Medium (10\")", price: 80),
            CustomizationOption(name: "Large (12\")", price: 150),
        ], isRequired: true, maxSelections: 1),
        CustomizationGroup(name: "Crust", options: [
            CustomizationOption(name: "Classic Hand Tossed", price: 0, isSelected: true),
            CustomizationOption(name: "Cheese Burst", price: 99),
            CustomizationOption(name: "Thin Crust", price: 30),
            CustomizationOption(name: "New York Style", price: 50),
        ], isRequired: true, maxSelections: 1),
        CustomizationGroup(name: "Extra Toppings", options: [
            CustomizationOption(name: "Paneer", price: 40),
            CustomizationOption(name: "Mushroom", price: 35),
            CustomizationOption(name: "Olives", price: 30),
            CustomizationOption(name: "Jalapeno", price: 25),
            CustomizationOption(name: "Corn", price: 20),
            CustomizationOption(name: "Extra Cheese", price: 50),
            CustomizationOption(name: "Onion", price: 15),
            CustomizationOption(name: "Capsicum", price: 15),
        ], isRequired: false, maxSelections: 8),
    ]
    
    static let burgerCustomizations: [CustomizationGroup] = [
        CustomizationGroup(name: "Patty", options: [
            CustomizationOption(name: "Classic Veg", price: 0, isSelected: true),
            CustomizationOption(name: "Crispy Chicken", price: 40),
            CustomizationOption(name: "Double Patty", price: 70),
        ], isRequired: true, maxSelections: 1),
        CustomizationGroup(name: "Add-ons", options: [
            CustomizationOption(name: "Extra Cheese Slice", price: 25),
            CustomizationOption(name: "Bacon", price: 50),
            CustomizationOption(name: "Egg", price: 20),
            CustomizationOption(name: "Jalapenos", price: 15),
        ], isRequired: false, maxSelections: 4),
    ]
    
    static let drinkCustomizations: [CustomizationGroup] = [
        CustomizationGroup(name: "Size", options: [
            CustomizationOption(name: "Regular", price: 0, isSelected: true),
            CustomizationOption(name: "Large", price: 30),
        ], isRequired: true, maxSelections: 1),
    ]
    
    // MARK: - 25 Restaurants with 150+ menu items
    
    public static let restaurants: [Restaurant] = [
        // 1
        Restaurant(
            id: "r1", name: "La Pino'z Pizza",
            categories: [.all, .pizza, .italian],
            rating: 3.9, numberOfRatings: 2400,
            deliveryTime: "10-15 mins", distance: "1 km",
            offer: "50% OFF up to ₹100",
            imageName: img(0), isPureVeg: false,
            menuItems: [
                MenuItem(id: "m1", name: "Margherita Pizza", price: 179, isVeg: true, imageName: img(0), rating: 4.5, numberOfRatings: 890, description: "Classic cheese pizza with fresh basil and tangy tomato sauce", isBestseller: true, isCustomisable: true, isHighlyOrdered: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m2", name: "Paneer Tikka Pizza", price: 299, isVeg: true, imageName: img(0), rating: 4.3, numberOfRatings: 650, description: "Loaded with spicy paneer tikka, onions, capsicum & mozzarella", isBestseller: true, isCustomisable: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m3", name: "Peppy Paneer Pizza", price: 259, isVeg: true, imageName: img(0), rating: 4.2, numberOfRatings: 420, description: "Crispy paneer cubes with capsicum, red paprika & spicy sauce", isCustomisable: true, isRecommended: true, menuSection: "Recommended", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m4", name: "Farm Fresh Pizza", price: 219, isVeg: true, imageName: img(0), rating: 4.1, numberOfRatings: 310, description: "Fresh mushroom, corn, tomato, onion with cheese", isCustomisable: true, menuSection: "Recommended", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m5", name: "Garlic Bread with Cheese", price: 129, isVeg: true, imageName: img(0), rating: 4.4, numberOfRatings: 560, description: "Toasted garlic bread topped with mozzarella cheese", isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m6", name: "Combo Meal for 2", price: 449, isVeg: true, imageName: img(0), rating: 4.0, numberOfRatings: 180, description: "2 Medium Pizzas + Garlic Bread + 2 Coke", menuSection: "Combos"),
                MenuItem(id: "m7", name: "Coca Cola", price: 60, isVeg: true, imageName: img(0), description: "Chilled 300ml bottle", menuSection: "Drinks", customizationGroups: drinkCustomizations),
                MenuItem(id: "m8", name: "Brownie with Ice Cream", price: 149, isVeg: true, imageName: img(3), rating: 4.6, numberOfRatings: 230, description: "Warm chocolate brownie served with vanilla ice cream", menuSection: "Desserts"),
            ],
            cuisineText: "Pizza, Italian, Fast Food",
            priceForTwo: 400, isFeatured: true,
            badges: ["Frequently Reordered"]
        ),
        // 2
        Restaurant(
            id: "r2", name: "Cravero Kitchen",
            categories: [.all, .paratha, .northIndian],
            rating: 3.8, numberOfRatings: 1800,
            deliveryTime: "15-20 mins", distance: "2 km",
            offer: "₹50 OFF above ₹199",
            imageName: img(2), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m9", name: "Aloo Paratha", price: 89, isVeg: true, imageName: img(2), rating: 4.4, numberOfRatings: 780, description: "Stuffed wheat flatbread with spiced potato filling, served with curd & pickle", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m10", name: "Paneer Paratha", price: 109, isVeg: true, imageName: img(2), rating: 4.3, numberOfRatings: 560, description: "Crispy paratha stuffed with seasoned cottage cheese", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m11", name: "Gobhi Paratha", price: 89, isVeg: true, imageName: img(2), rating: 4.1, numberOfRatings: 320, description: "Cauliflower stuffed paratha with fresh green chutney", isRecommended: true, menuSection: "Recommended"),
                MenuItem(id: "m12", name: "Mix Veg Paratha", price: 99, isVeg: true, imageName: img(2), rating: 4.0, numberOfRatings: 210, description: "Loaded with seasonal vegetables and Indian spices", menuSection: "Recommended"),
                MenuItem(id: "m13", name: "Dal Makhani", price: 169, isVeg: true, imageName: img(2), rating: 4.5, numberOfRatings: 450, description: "Slow-cooked black lentils in creamy tomato gravy", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m14", name: "Lassi", price: 59, isVeg: true, imageName: img(2), description: "Thick and creamy yogurt drink", menuSection: "Drinks"),
            ],
            cuisineText: "Paratha, North Indian, Punjabi",
            priceForTwo: 250,
            badges: ["Pure Veg", "Low Plastic Packaging"]
        ),
        // 3
        Restaurant(
            id: "r3", name: "Da Pepper Pizza",
            categories: [.all, .pizza],
            rating: 3.9, numberOfRatings: 1200,
            deliveryTime: "30-35 mins", distance: "3 km",
            offer: "₹100 OFF above ₹199",
            imageName: img(0), isPureVeg: false,
            menuItems: [
                MenuItem(id: "m15", name: "Peri Peri Chicken Pizza", price: 349, isVeg: false, imageName: img(0), rating: 4.4, numberOfRatings: 340, description: "Spicy peri-peri chicken with bell peppers & onion rings", isBestseller: true, isCustomisable: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m16", name: "BBQ Chicken Pizza", price: 379, isVeg: false, imageName: img(0), rating: 4.3, numberOfRatings: 280, description: "Smokey BBQ chicken with caramelized onions", isCustomisable: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m17", name: "Veggie Supreme", price: 289, isVeg: true, imageName: img(0), rating: 4.1, numberOfRatings: 200, description: "Loaded with 7 fresh vegetables and mozzarella", isCustomisable: true, isRecommended: true, menuSection: "Recommended", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m18", name: "Choco Lava Cake", price: 99, isVeg: true, imageName: img(3), rating: 4.7, numberOfRatings: 450, description: "Warm molten chocolate cake with gooey center", isBestseller: true, menuSection: "Desserts"),
                MenuItem(id: "m19", name: "Combo for 4", price: 799, isVeg: false, imageName: img(0), description: "2 Large Pizzas + Garlic Bread + 4 Drinks", menuSection: "Combos"),
                MenuItem(id: "m20", name: "Cheesy Fries", price: 139, isVeg: true, imageName: img(1), rating: 4.2, numberOfRatings: 310, description: "Crispy french fries loaded with cheddar cheese sauce", menuSection: "Recommended"),
            ],
            cuisineText: "Pizza, Fast Food",
            priceForTwo: 500
        ),
        // 4
        Restaurant(
            id: "r4", name: "Burger Belly",
            categories: [.all, .burger],
            rating: 4.2, numberOfRatings: 3100,
            deliveryTime: "20-25 mins", distance: "1 km",
            offer: "Flat ₹40 OFF",
            imageName: img(1), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m21", name: "Classic Veg Burger", price: 129, isVeg: true, imageName: img(1), rating: 4.3, numberOfRatings: 890, description: "Crispy veg patty with lettuce, tomato, onion & special sauce", isBestseller: true, isCustomisable: true, isHighlyOrdered: true, menuSection: "Most Ordered", customizationGroups: burgerCustomizations),
                MenuItem(id: "m22", name: "Paneer Royale Burger", price: 179, isVeg: true, imageName: img(1), rating: 4.4, numberOfRatings: 670, description: "Grilled paneer patty with caramelized onions & cheese slice", isBestseller: true, isCustomisable: true, menuSection: "Most Ordered", customizationGroups: burgerCustomizations),
                MenuItem(id: "m23", name: "Mexican Crunch Burger", price: 159, isVeg: true, imageName: img(1), rating: 4.1, numberOfRatings: 340, description: "Spicy bean patty with jalapenos, salsa & sour cream", isCustomisable: true, isRecommended: true, menuSection: "Recommended", customizationGroups: burgerCustomizations),
                MenuItem(id: "m24", name: "Fries Combo", price: 199, isVeg: true, imageName: img(1), description: "Any burger + Fries + Drink", menuSection: "Combos"),
                MenuItem(id: "m25", name: "Thick Shake - Oreo", price: 149, isVeg: true, imageName: img(1), rating: 4.5, numberOfRatings: 230, description: "Creamy Oreo milkshake topped with whipped cream", menuSection: "Drinks"),
                MenuItem(id: "m26", name: "Chocolate Sundae", price: 119, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 180, description: "Rich chocolate ice cream with fudge sauce & nuts", menuSection: "Desserts"),
            ],
            cuisineText: "Burger, Fast Food, American",
            priceForTwo: 350, isFeatured: true,
            badges: ["Pure Veg", "Frequently Reordered"]
        ),
        // 5
        Restaurant(
            id: "r5", name: "Dragon Wok",
            categories: [.all, .chinese],
            rating: 4.0, numberOfRatings: 2200,
            deliveryTime: "25-30 mins", distance: "2.5 km",
            offer: "20% OFF up to ₹120",
            imageName: img(3),
            menuItems: [
                MenuItem(id: "m27", name: "Veg Hakka Noodles", price: 159, isVeg: true, imageName: img(3), rating: 4.2, numberOfRatings: 670, description: "Stir-fried noodles with fresh vegetables in soy sauce", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m28", name: "Manchurian Gravy", price: 179, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 540, description: "Deep fried vegetable balls in spicy Indo-Chinese gravy", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m29", name: "Chicken Fried Rice", price: 199, isVeg: false, imageName: img(3), rating: 4.1, numberOfRatings: 380, description: "Wok-tossed rice with chicken, egg & vegetables", isRecommended: true, menuSection: "Recommended"),
                MenuItem(id: "m30", name: "Chilli Paneer Dry", price: 189, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 410, description: "Crispy paneer cubes tossed with bell peppers in chilli sauce", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m31", name: "Spring Rolls (6 pcs)", price: 139, isVeg: true, imageName: img(3), rating: 4.0, numberOfRatings: 250, description: "Crispy rolls stuffed with cabbage, carrots & noodles", menuSection: "Recommended"),
                MenuItem(id: "m32", name: "Noodles Combo", price: 299, isVeg: true, imageName: img(3), description: "Noodles + Manchurian + Coke", menuSection: "Combos"),
            ],
            cuisineText: "Chinese, Asian, Indo-Chinese",
            priceForTwo: 400
        ),
        // 6
        Restaurant(
            id: "r6", name: "Biryani Blues",
            categories: [.all, .biryani],
            rating: 4.3, numberOfRatings: 5600,
            deliveryTime: "30-40 mins", distance: "3 km",
            offer: "₹75 OFF above ₹299",
            imageName: img(2),
            menuItems: [
                MenuItem(id: "m33", name: "Hyderabadi Chicken Biryani", price: 299, isVeg: false, imageName: img(2), rating: 4.6, numberOfRatings: 2300, description: "Authentic dum-cooked biryani with tender chicken, fragrant basmati & saffron", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m34", name: "Veg Biryani", price: 219, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 890, description: "Aromatic vegetable biryani with fresh herbs and whole spices", isRecommended: true, menuSection: "Recommended"),
                MenuItem(id: "m35", name: "Mutton Biryani", price: 399, isVeg: false, imageName: img(2), rating: 4.5, numberOfRatings: 1200, description: "Slow-cooked mutton pieces in fragrant long-grain rice", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m36", name: "Chicken 65", price: 199, isVeg: false, imageName: img(2), rating: 4.3, numberOfRatings: 670, description: "Spicy deep-fried chicken seasoned with red chillies & curry leaves", menuSection: "Recommended"),
                MenuItem(id: "m37", name: "Raita", price: 49, isVeg: true, imageName: img(2), description: "Cool yogurt with cucumber, onion & mint", menuSection: "Recommended"),
                MenuItem(id: "m38", name: "Biryani Combo", price: 399, isVeg: false, imageName: img(2), description: "Biryani + Raita + Kebab + Drink", menuSection: "Combos"),
                MenuItem(id: "m39", name: "Gulab Jamun (2 pcs)", price: 69, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 340, description: "Soft milk dumplings soaked in rose-flavored sugar syrup", menuSection: "Desserts"),
            ],
            cuisineText: "Biryani, Hyderabadi, Mughlai",
            priceForTwo: 550, isFeatured: true,
            badges: ["Frequently Reordered", "Top Rated"]
        ),
        // 7
        Restaurant(
            id: "r7", name: "Madras Café",
            categories: [.all, .southIndian],
            rating: 4.1, numberOfRatings: 1900,
            deliveryTime: "15-20 mins", distance: "1.5 km",
            offer: "₹30 OFF above ₹149",
            imageName: img(2), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m40", name: "Masala Dosa", price: 99, isVeg: true, imageName: img(2), rating: 4.5, numberOfRatings: 980, description: "Crispy rice crepe stuffed with spiced potato filling, served with sambar & chutney", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m41", name: "Idli Sambar (4 pcs)", price: 79, isVeg: true, imageName: img(2), rating: 4.3, numberOfRatings: 670, description: "Soft steamed rice cakes with lentil soup & coconut chutney", isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m42", name: "Medu Vada (2 pcs)", price: 69, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 430, description: "Crispy fried lentil donuts with sambar & chutney", menuSection: "Recommended"),
                MenuItem(id: "m43", name: "Rava Upma", price: 79, isVeg: true, imageName: img(2), rating: 4.0, numberOfRatings: 210, description: "Semolina dish cooked with mustard seeds, curry leaves & vegetables", menuSection: "Recommended"),
                MenuItem(id: "m44", name: "Filter Coffee", price: 49, isVeg: true, imageName: img(2), rating: 4.7, numberOfRatings: 560, description: "Authentic South Indian filter coffee with frothy milk", isBestseller: true, menuSection: "Drinks"),
                MenuItem(id: "m45", name: "Mysore Pak", price: 89, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 190, description: "Traditional ghee-rich gram flour sweet", menuSection: "Desserts"),
            ],
            cuisineText: "South Indian, Coffee, Breakfast",
            priceForTwo: 200,
            badges: ["Pure Veg"]
        ),
        // 8
        Restaurant(
            id: "r8", name: "Roll Junction",
            categories: [.all, .rolls, .streetFood],
            rating: 3.7, numberOfRatings: 980,
            deliveryTime: "10-15 mins", distance: "0.8 km",
            offer: "Buy 1 Get 1 Free",
            imageName: img(2),
            menuItems: [
                MenuItem(id: "m46", name: "Paneer Tikka Roll", price: 129, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 340, description: "Grilled paneer wrapped in flaky paratha with mint chutney & onions", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m47", name: "Chicken Seekh Roll", price: 149, isVeg: false, imageName: img(2), rating: 4.3, numberOfRatings: 280, description: "Juicy chicken seekh kebab roll with green chutney", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m48", name: "Egg Roll", price: 89, isVeg: false, imageName: img(2), rating: 4.0, numberOfRatings: 190, description: "Double egg roll with onions, chutney & spices", menuSection: "Recommended"),
                MenuItem(id: "m49", name: "Aloo Tikki Roll", price: 99, isVeg: true, imageName: img(2), rating: 3.9, numberOfRatings: 150, description: "Crispy potato tikki with tangy tamarind sauce", menuSection: "Recommended"),
                MenuItem(id: "m50", name: "Roll Combo (2 Rolls + Drink)", price: 249, isVeg: false, imageName: img(2), description: "Any 2 rolls with a cold drink", menuSection: "Combos"),
            ],
            cuisineText: "Rolls, Wraps, Street Food",
            priceForTwo: 250
        ),
        // 9
        Restaurant(
            id: "r9", name: "Sweet Surrender",
            categories: [.all, .desserts, .coffee],
            rating: 4.4, numberOfRatings: 3200,
            deliveryTime: "20-25 mins", distance: "2 km",
            offer: "Free Delivery",
            imageName: img(3), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m51", name: "Belgian Chocolate Truffle", price: 199, isVeg: true, imageName: img(3), rating: 4.8, numberOfRatings: 1200, description: "Rich and dense dark chocolate truffle cake slice", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m52", name: "Red Velvet Pastry", price: 149, isVeg: true, imageName: img(3), rating: 4.6, numberOfRatings: 890, description: "Moist red velvet cake with cream cheese frosting", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m53", name: "Tiramisu", price: 249, isVeg: true, imageName: img(3), rating: 4.7, numberOfRatings: 560, description: "Classic Italian dessert with espresso-soaked ladyfingers & mascarpone", isRecommended: true, menuSection: "Recommended"),
                MenuItem(id: "m54", name: "Cheesecake", price: 229, isVeg: true, imageName: img(3), rating: 4.5, numberOfRatings: 430, description: "New York style baked cheesecake with berry compote", menuSection: "Recommended"),
                MenuItem(id: "m55", name: "Cold Coffee", price: 129, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 340, description: "Blended iced coffee with cream and chocolate drizzle", menuSection: "Drinks"),
                MenuItem(id: "m56", name: "Dessert Box (4 pcs)", price: 499, isVeg: true, imageName: img(3), description: "Assorted pastries - Truffle, Red Velvet, Blueberry, Butterscotch", menuSection: "Combos"),
            ],
            cuisineText: "Desserts, Bakery, Coffee",
            priceForTwo: 400, isFeatured: true,
            badges: ["Pure Veg", "Top Rated"]
        ),
        // 10
        Restaurant(
            id: "r10", name: "The Italian Job",
            categories: [.all, .italian, .pizza],
            rating: 4.1, numberOfRatings: 1500,
            deliveryTime: "25-35 mins", distance: "3.5 km",
            offer: "₹80 OFF above ₹349",
            imageName: img(0),
            menuItems: [
                MenuItem(id: "m57", name: "Pasta Alfredo", price: 249, isVeg: true, imageName: img(0), rating: 4.4, numberOfRatings: 450, description: "Creamy white sauce pasta with mushrooms, bell peppers & herbs", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m58", name: "Penne Arrabbiata", price: 229, isVeg: true, imageName: img(0), rating: 4.2, numberOfRatings: 320, description: "Spicy tomato sauce pasta with garlic, chilli flakes & basil", menuSection: "Recommended"),
                MenuItem(id: "m59", name: "Chicken Lasagna", price: 329, isVeg: false, imageName: img(0), rating: 4.5, numberOfRatings: 280, description: "Layered pasta sheets with chicken, béchamel & bolognese sauce", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m60", name: "Bruschetta", price: 149, isVeg: true, imageName: img(0), rating: 4.1, numberOfRatings: 190, description: "Toasted bread with diced tomatoes, basil & olive oil", menuSection: "Recommended"),
                MenuItem(id: "m61", name: "Wood Fired Quattro Formaggi", price: 399, isVeg: true, imageName: img(0), rating: 4.6, numberOfRatings: 210, description: "Four cheese pizza with mozzarella, cheddar, parmesan & gorgonzola", isCustomisable: true, menuSection: "Recommended", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m62", name: "Pasta + Pizza Combo", price: 549, isVeg: true, imageName: img(0), description: "Any Pasta + Medium Pizza + 2 Drinks", menuSection: "Combos"),
            ],
            cuisineText: "Italian, Pasta, Pizza",
            priceForTwo: 600
        ),
        // 11
        Restaurant(
            id: "r11", name: "Desi Dhaba",
            categories: [.all, .northIndian, .thali],
            rating: 3.8, numberOfRatings: 2800,
            deliveryTime: "20-30 mins", distance: "2 km",
            offer: "₹60 OFF above ₹249",
            imageName: img(2), isPureVeg: false,
            menuItems: [
                MenuItem(id: "m63", name: "Butter Chicken", price: 269, isVeg: false, imageName: img(2), rating: 4.5, numberOfRatings: 1100, description: "Tender chicken in rich, creamy tomato-butter gravy", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m64", name: "Paneer Butter Masala", price: 229, isVeg: true, imageName: img(2), rating: 4.4, numberOfRatings: 890, description: "Soft paneer cubes in smooth, buttery tomato gravy", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m65", name: "Dal Tadka", price: 149, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 560, description: "Yellow lentils tempered with cumin, garlic & ghee", menuSection: "Recommended"),
                MenuItem(id: "m66", name: "Tandoori Roti (2 pcs)", price: 49, isVeg: true, imageName: img(2), description: "Fresh clay oven baked whole wheat bread", menuSection: "Recommended"),
                MenuItem(id: "m67", name: "Naan", price: 39, isVeg: true, imageName: img(2), description: "Soft leavened bread baked in tandoor", menuSection: "Recommended"),
                MenuItem(id: "m68", name: "Non-Veg Thali", price: 349, isVeg: false, imageName: img(2), rating: 4.3, numberOfRatings: 450, description: "Butter Chicken + Dal + Rice + 3 Rotis + Raita + Salad + Gulab Jamun", menuSection: "Combos"),
                MenuItem(id: "m69", name: "Veg Thali", price: 249, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 380, description: "Paneer + Dal + Rice + 3 Rotis + Raita + Salad + Sweet", menuSection: "Combos"),
            ],
            cuisineText: "North Indian, Mughlai, Punjabi",
            priceForTwo: 500,
            badges: ["Frequently Reordered"]
        ),
        // 12
        Restaurant(
            id: "r12", name: "Green Leaf Salads",
            categories: [.all, .healthy],
            rating: 4.3, numberOfRatings: 1100,
            deliveryTime: "15-20 mins", distance: "1.2 km",
            offer: "15% OFF above ₹199",
            imageName: img(3), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m70", name: "Caesar Salad", price: 199, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 340, description: "Crispy romaine lettuce with parmesan, croutons & Caesar dressing", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m71", name: "Quinoa Power Bowl", price: 279, isVeg: true, imageName: img(3), rating: 4.5, numberOfRatings: 230, description: "Quinoa with avocado, cherry tomatoes, chickpeas & tahini dressing", isRecommended: true, menuSection: "Recommended"),
                MenuItem(id: "m72", name: "Greek Salad", price: 179, isVeg: true, imageName: img(3), rating: 4.2, numberOfRatings: 190, description: "Cucumber, olives, feta cheese, tomato with olive oil & oregano", menuSection: "Recommended"),
                MenuItem(id: "m73", name: "Berry Smoothie", price: 149, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 280, description: "Mixed berry smoothie with Greek yogurt & honey", menuSection: "Drinks"),
                MenuItem(id: "m74", name: "Protein Bowl", price: 299, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 210, description: "Grilled paneer, brown rice, broccoli, sweet potato & peanut sauce", menuSection: "Recommended"),
            ],
            cuisineText: "Healthy, Salads, Bowls",
            priceForTwo: 350,
            badges: ["Pure Veg", "Healthy Choice"]
        ),
        // 13
        Restaurant(
            id: "r13", name: "Chai Pe Charcha",
            categories: [.all, .coffee, .streetFood],
            rating: 4.0, numberOfRatings: 1400,
            deliveryTime: "10-15 mins", distance: "0.5 km",
            offer: "Free Bun Maska on ₹199+",
            imageName: img(3), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m75", name: "Masala Chai", price: 39, isVeg: true, imageName: img(3), rating: 4.6, numberOfRatings: 890, description: "Aromatic spiced tea with ginger, cardamom & fresh milk", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m76", name: "Cutting Chai", price: 25, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 670, description: "Mumbai-style half glass strong tea", menuSection: "Most Ordered"),
                MenuItem(id: "m77", name: "Bun Maska", price: 49, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 430, description: "Soft Irani bun generously slathered with creamy butter", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m78", name: "Cappuccino", price: 99, isVeg: true, imageName: img(3), rating: 4.2, numberOfRatings: 320, description: "Espresso with steamed milk and thick foam", menuSection: "Drinks"),
                MenuItem(id: "m79", name: "Vada Pav", price: 39, isVeg: true, imageName: img(3), rating: 4.5, numberOfRatings: 560, description: "Mumbai's iconic spicy potato fritter in a pav bun", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m80", name: "Tea Time Combo", price: 99, isVeg: true, imageName: img(3), description: "2 Cutting Chai + 2 Bun Maska", menuSection: "Combos"),
            ],
            cuisineText: "Cafe, Tea, Street Food",
            priceForTwo: 150
        ),
        // 14
        Restaurant(
            id: "r14", name: "Tandoori Nights",
            categories: [.all, .northIndian],
            rating: 4.2, numberOfRatings: 2100,
            deliveryTime: "25-35 mins", distance: "2.8 km",
            offer: "₹100 OFF above ₹399",
            imageName: img(2),
            menuItems: [
                MenuItem(id: "m81", name: "Tandoori Chicken (Half)", price: 249, isVeg: false, imageName: img(2), rating: 4.5, numberOfRatings: 780, description: "Marinated chicken legs roasted in clay oven with smoky flavor", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m82", name: "Malai Tikka", price: 269, isVeg: false, imageName: img(2), rating: 4.4, numberOfRatings: 560, description: "Creamy, melt-in-mouth chicken tikka marinated in cashew paste", menuSection: "Most Ordered"),
                MenuItem(id: "m83", name: "Paneer Tikka (8 pcs)", price: 229, isVeg: true, imageName: img(2), rating: 4.3, numberOfRatings: 430, description: "Marinated cottage cheese cubes grilled with bell peppers", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m84", name: "Seekh Kebab (4 pcs)", price: 199, isVeg: false, imageName: img(2), rating: 4.2, numberOfRatings: 320, description: "Minced chicken kebabs with aromatic spices, grilled on skewers", menuSection: "Recommended"),
                MenuItem(id: "m85", name: "Rumali Roti (2 pcs)", price: 59, isVeg: true, imageName: img(2), description: "Paper-thin soft bread cooked on inverted tawa", menuSection: "Recommended"),
                MenuItem(id: "m86", name: "Tandoori Platter", price: 599, isVeg: false, imageName: img(2), description: "Tandoori Chicken + Seekh Kebab + Malai Tikka + Naan + Chutney", menuSection: "Combos"),
            ],
            cuisineText: "Tandoor, North Indian, Kebabs",
            priceForTwo: 600
        ),
        // 15
        Restaurant(
            id: "r15", name: "Chill With Cheese",
            categories: [.all, .pizza, .burger],
            rating: 3.5, numberOfRatings: 750,
            deliveryTime: "15-20 mins", distance: "1.5 km",
            offer: "₹125 OFF above ₹399",
            imageName: img(3),
            menuItems: [
                MenuItem(id: "m87", name: "Cheese Burst Pizza", price: 349, isVeg: true, imageName: img(0), rating: 4.1, numberOfRatings: 230, description: "Loaded cheese burst crust with triple cheese topping", isBestseller: true, isCustomisable: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m88", name: "Mac & Cheese", price: 179, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 340, description: "Creamy elbow pasta in cheddar cheese sauce", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m89", name: "Cheese Fries", price: 129, isVeg: true, imageName: img(1), rating: 4.0, numberOfRatings: 210, description: "Crispy fries loaded with melted cheese & jalapenos", menuSection: "Recommended"),
                MenuItem(id: "m90", name: "Grilled Cheese Sandwich", price: 119, isVeg: true, imageName: img(3), rating: 4.2, numberOfRatings: 180, description: "Golden toasted sandwich with 3 types of cheese", menuSection: "Recommended"),
                MenuItem(id: "m91", name: "Cheese Platter", price: 499, isVeg: true, imageName: img(3), description: "Pizza + Mac & Cheese + Cheese Fries + 2 Drinks", menuSection: "Combos"),
            ],
            cuisineText: "Cheese, Pizza, Fast Food",
            priceForTwo: 450
        ),
        // 16
        Restaurant(
            id: "r16", name: "Spice Route",
            categories: [.all, .biryani, .northIndian],
            rating: 4.0, numberOfRatings: 1600,
            deliveryTime: "30-40 mins", distance: "4 km",
            offer: "₹50 OFF above ₹199",
            imageName: img(2),
            menuItems: [
                MenuItem(id: "m92", name: "Lucknowi Chicken Biryani", price: 279, isVeg: false, imageName: img(2), rating: 4.4, numberOfRatings: 560, description: "Fragrant Awadhi-style biryani with succulent chicken & saffron rice", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m93", name: "Egg Biryani", price: 179, isVeg: false, imageName: img(2), rating: 4.0, numberOfRatings: 230, description: "Fluffy biryani rice with boiled eggs & aromatic spices", menuSection: "Recommended"),
                MenuItem(id: "m94", name: "Chicken Korma", price: 249, isVeg: false, imageName: img(2), rating: 4.3, numberOfRatings: 380, description: "Rich and creamy cashew-based curry with tender chicken", menuSection: "Recommended"),
                MenuItem(id: "m95", name: "Shahi Paneer", price: 219, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 290, description: "Royal paneer curry in rich cashew-cream gravy", menuSection: "Most Ordered"),
                MenuItem(id: "m96", name: "Jeera Rice", price: 99, isVeg: true, imageName: img(2), description: "Fragrant basmati rice tempered with cumin seeds", menuSection: "Recommended"),
                MenuItem(id: "m97", name: "Family Feast", price: 699, isVeg: false, imageName: img(2), description: "2 Biryani + Korma + 4 Rotis + Raita + 2 Drinks", menuSection: "Combos"),
            ],
            cuisineText: "Biryani, Lucknowi, Mughlai",
            priceForTwo: 550, isSponsored: true
        ),
        // 17
        Restaurant(
            id: "r17", name: "Wok This Way",
            categories: [.all, .chinese, .rolls],
            rating: 3.6, numberOfRatings: 620,
            deliveryTime: "15-25 mins", distance: "1.8 km",
            imageName: img(3),
            menuItems: [
                MenuItem(id: "m98", name: "Szechuan Noodles", price: 169, isVeg: true, imageName: img(3), rating: 4.1, numberOfRatings: 210, description: "Fiery Szechuan pepper noodles with vegetables", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m99", name: "Kung Pao Paneer", price: 199, isVeg: true, imageName: img(3), rating: 4.2, numberOfRatings: 180, description: "Paneer stir-fried with peanuts, dried chillies in sweet-sour sauce", menuSection: "Recommended"),
                MenuItem(id: "m100", name: "Dim Sum (6 pcs)", price: 179, isVeg: true, imageName: img(3), rating: 4.0, numberOfRatings: 150, description: "Steamed vegetable dumplings with soy-chilli dip", menuSection: "Recommended"),
                MenuItem(id: "m101", name: "Hot & Sour Soup", price: 99, isVeg: true, imageName: img(3), rating: 4.1, numberOfRatings: 190, description: "Spicy and tangy vegetable soup with tofu", menuSection: "Recommended"),
                MenuItem(id: "m102", name: "Wok Combo", price: 299, isVeg: true, imageName: img(3), description: "Noodles + Manchurian + Soup", menuSection: "Combos"),
            ],
            cuisineText: "Chinese, Pan-Asian",
            priceForTwo: 350
        ),
        // 18
        Restaurant(
            id: "r18", name: "Dosa Factory",
            categories: [.all, .southIndian],
            rating: 4.0, numberOfRatings: 1300,
            deliveryTime: "15-20 mins", distance: "1 km",
            offer: "₹40 OFF above ₹149",
            imageName: img(2), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m103", name: "Mysore Masala Dosa", price: 109, isVeg: true, imageName: img(2), rating: 4.4, numberOfRatings: 560, description: "Crispy dosa with spicy Mysore chutney & potato masala", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m104", name: "Cheese Dosa", price: 129, isVeg: true, imageName: img(2), rating: 4.3, numberOfRatings: 430, description: "Golden dosa loaded with melted mozzarella cheese", menuSection: "Most Ordered"),
                MenuItem(id: "m105", name: "Paper Roast Dosa", price: 99, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 320, description: "Extra thin and crispy plain dosa, 2 feet long!", menuSection: "Recommended"),
                MenuItem(id: "m106", name: "Uttapam", price: 89, isVeg: true, imageName: img(2), rating: 4.0, numberOfRatings: 210, description: "Thick rice pancake topped with onion, tomato & green chilli", menuSection: "Recommended"),
                MenuItem(id: "m107", name: "South Indian Combo", price: 179, isVeg: true, imageName: img(2), description: "Dosa + Idli (2) + Vada (1) + Filter Coffee", menuSection: "Combos"),
            ],
            cuisineText: "South Indian, Dosa, Breakfast",
            priceForTwo: 200,
            badges: ["Pure Veg"]
        ),
        // 19
        Restaurant(
            id: "r19", name: "Empire Meals",
            categories: [.all, .biryani, .northIndian],
            rating: 4.1, numberOfRatings: 2400,
            deliveryTime: "25-30 mins", distance: "2.5 km",
            offer: "30% OFF up to ₹75",
            imageName: img(2),
            menuItems: [
                MenuItem(id: "m108", name: "Chicken Biryani Special", price: 259, isVeg: false, imageName: img(2), rating: 4.4, numberOfRatings: 980, description: "Signature Empire biryani with extra large chicken pieces", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m109", name: "Shawarma (2 pcs)", price: 149, isVeg: false, imageName: img(2), rating: 4.2, numberOfRatings: 560, description: "Lebanese-style chicken shawarma with garlic sauce", menuSection: "Most Ordered"),
                MenuItem(id: "m110", name: "Chicken Kebab Platter", price: 299, isVeg: false, imageName: img(2), rating: 4.3, numberOfRatings: 340, description: "Assorted kebabs - Seekh, Malai, Afghani with mint chutney", menuSection: "Recommended"),
                MenuItem(id: "m111", name: "Mutton Rogan Josh", price: 329, isVeg: false, imageName: img(2), rating: 4.5, numberOfRatings: 280, description: "Kashmiri-style tender mutton in aromatic red gravy", menuSection: "Recommended"),
                MenuItem(id: "m112", name: "Empire Special Thali", price: 399, isVeg: false, imageName: img(2), description: "Biryani + Kebab + Curry + Naan + Raita + Drink", menuSection: "Combos"),
            ],
            cuisineText: "Biryani, Mughlai, Kebabs",
            priceForTwo: 500, isFeatured: true,
            badges: ["Top Rated"]
        ),
        // 20
        Restaurant(
            id: "r20", name: "Pizza Paradise",
            categories: [.all, .pizza, .italian],
            rating: 3.7, numberOfRatings: 890,
            deliveryTime: "20-30 mins", distance: "3 km",
            offer: "₹150 OFF above ₹499",
            imageName: img(0),
            menuItems: [
                MenuItem(id: "m113", name: "Tandoori Paneer Pizza", price: 329, isVeg: true, imageName: img(0), rating: 4.2, numberOfRatings: 280, description: "Tandoori paneer with onion, capsicum & tikka sauce", isBestseller: true, isCustomisable: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m114", name: "Chicken Supreme Pizza", price: 389, isVeg: false, imageName: img(0), rating: 4.3, numberOfRatings: 340, description: "Loaded chicken with olives, jalapenos, onions & bell peppers", isCustomisable: true, menuSection: "Most Ordered", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m115", name: "Mushroom Truffle Pizza", price: 449, isVeg: true, imageName: img(0), rating: 4.5, numberOfRatings: 190, description: "Wild mushrooms with truffle oil, arugula & parmesan", menuSection: "Recommended", customizationGroups: pizzaCustomizations),
                MenuItem(id: "m116", name: "Stuffed Garlic Bread", price: 149, isVeg: true, imageName: img(0), rating: 4.1, numberOfRatings: 230, description: "Garlic bread stuffed with corn, cheese & jalapenos", menuSection: "Recommended"),
                MenuItem(id: "m117", name: "Party Combo", price: 999, isVeg: false, imageName: img(0), description: "2 Large Pizzas + 2 Garlic Breads + 4 Drinks + Brownie", menuSection: "Combos"),
            ],
            cuisineText: "Pizza, Italian, Fast Food",
            priceForTwo: 550, isSponsored: true
        ),
        // 21
        Restaurant(
            id: "r21", name: "Bombay Street Kitchen",
            categories: [.all, .streetFood],
            rating: 3.9, numberOfRatings: 1700,
            deliveryTime: "10-15 mins", distance: "0.6 km",
            offer: "Buy 2 Get 1 Free",
            imageName: img(2), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m118", name: "Pav Bhaji", price: 99, isVeg: true, imageName: img(2), rating: 4.5, numberOfRatings: 780, description: "Mumbai's iconic buttery mashed vegetable curry with toasted pav buns", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m119", name: "Sev Puri (6 pcs)", price: 79, isVeg: true, imageName: img(2), rating: 4.3, numberOfRatings: 450, description: "Crispy puri topped with potatoes, chutneys, onion & thin sev", menuSection: "Most Ordered"),
                MenuItem(id: "m120", name: "Bhel Puri", price: 69, isVeg: true, imageName: img(2), rating: 4.2, numberOfRatings: 340, description: "Puffed rice mixed with vegetables, tamarind & green chutney", menuSection: "Recommended"),
                MenuItem(id: "m121", name: "Dahi Puri (6 pcs)", price: 89, isVeg: true, imageName: img(2), rating: 4.1, numberOfRatings: 290, description: "Crispy puri filled with yogurt, potatoes, chutneys & sev", menuSection: "Recommended"),
                MenuItem(id: "m122", name: "Samosa (2 pcs)", price: 49, isVeg: true, imageName: img(2), rating: 4.4, numberOfRatings: 560, description: "Crispy fried pastry filled with spiced potato & peas", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m123", name: "Chat Platter", price: 199, isVeg: true, imageName: img(2), description: "Pav Bhaji + Sev Puri + Samosa + Masala Chai", menuSection: "Combos"),
            ],
            cuisineText: "Street Food, Chaat, Mumbai",
            priceForTwo: 200,
            badges: ["Pure Veg", "Near & Fast"]
        ),
        // 22
        Restaurant(
            id: "r22", name: "Royal Mughal",
            categories: [.all, .northIndian, .biryani],
            rating: 4.4, numberOfRatings: 4200,
            deliveryTime: "35-45 mins", distance: "5 km",
            offer: "Flat ₹120 OFF",
            imageName: img(2),
            menuItems: [
                MenuItem(id: "m124", name: "Mughlai Chicken Biryani", price: 329, isVeg: false, imageName: img(2), rating: 4.7, numberOfRatings: 1800, description: "Royal Mughlai biryani with bone-in chicken, dry fruits & saffron", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m125", name: "Nihari Gosht", price: 399, isVeg: false, imageName: img(2), rating: 4.6, numberOfRatings: 890, description: "Slow-cooked overnight mutton stew, Mughal royalty's breakfast dish", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m126", name: "Galouti Kebab (4 pcs)", price: 279, isVeg: false, imageName: img(2), rating: 4.5, numberOfRatings: 560, description: "Melt-in-mouth Lucknowi kebabs made with 150+ spices", menuSection: "Recommended"),
                MenuItem(id: "m127", name: "Shahi Tukda", price: 129, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 340, description: "Royal Mughal bread pudding with rabri, saffron & pistachios", menuSection: "Desserts"),
                MenuItem(id: "m128", name: "Phirni", price: 99, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 230, description: "Creamy ground rice pudding set in clay pots, served chilled", menuSection: "Desserts"),
                MenuItem(id: "m129", name: "Royal Feast", price: 899, isVeg: false, imageName: img(2), description: "Biryani + Nihari + Galouti + 4 Rumali + Phirni", menuSection: "Combos"),
            ],
            cuisineText: "Mughlai, Lucknowi, Kebabs",
            priceForTwo: 700, isFeatured: true,
            badges: ["Top Rated", "Premium"]
        ),
        // 23
        Restaurant(
            id: "r23", name: "Taco Bell Express",
            categories: [.all, .streetFood, .burger],
            rating: 3.8, numberOfRatings: 1100,
            deliveryTime: "20-25 mins", distance: "2 km",
            offer: "₹70 OFF above ₹249",
            imageName: img(1),
            menuItems: [
                MenuItem(id: "m130", name: "Crunchy Taco", price: 99, isVeg: false, imageName: img(1), rating: 4.2, numberOfRatings: 340, description: "Crispy corn shell filled with seasoned chicken, lettuce & cheese", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m131", name: "Veg Burrito", price: 179, isVeg: true, imageName: img(1), rating: 4.1, numberOfRatings: 230, description: "Flour tortilla wrapped with rice, beans, cheese & salsa", menuSection: "Most Ordered"),
                MenuItem(id: "m132", name: "Nachos Supreme", price: 149, isVeg: true, imageName: img(1), rating: 4.3, numberOfRatings: 280, description: "Crispy tortilla chips loaded with cheese sauce, jalapenos & salsa", isRecommended: true, menuSection: "Recommended"),
                MenuItem(id: "m133", name: "Quesadilla", price: 159, isVeg: true, imageName: img(1), rating: 4.0, numberOfRatings: 190, description: "Grilled flour tortilla stuffed with melted cheese & vegetables", menuSection: "Recommended"),
                MenuItem(id: "m134", name: "Taco Party Pack", price: 349, isVeg: false, imageName: img(1), description: "4 Tacos + Nachos + 2 Drinks", menuSection: "Combos"),
            ],
            cuisineText: "Mexican, Fast Food, Tacos",
            priceForTwo: 350
        ),
        // 24
        Restaurant(
            id: "r24", name: "Sushi & More",
            categories: [.all, .chinese, .healthy],
            rating: 4.2, numberOfRatings: 800,
            deliveryTime: "30-40 mins", distance: "4 km",
            offer: "20% OFF above ₹399",
            imageName: img(3),
            menuItems: [
                MenuItem(id: "m135", name: "California Roll (8 pcs)", price: 349, isVeg: false, imageName: img(3), rating: 4.5, numberOfRatings: 280, description: "Inside-out roll with crab stick, avocado & cucumber", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m136", name: "Veg Tempura Roll (6 pcs)", price: 279, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 190, description: "Crispy tempura vegetables wrapped in sushi rice & nori", menuSection: "Recommended"),
                MenuItem(id: "m137", name: "Miso Soup", price: 129, isVeg: true, imageName: img(3), rating: 4.1, numberOfRatings: 150, description: "Traditional Japanese soup with tofu, seaweed & green onion", menuSection: "Recommended"),
                MenuItem(id: "m138", name: "Edamame", price: 149, isVeg: true, imageName: img(3), rating: 4.0, numberOfRatings: 120, description: "Steamed young soybeans sprinkled with sea salt", menuSection: "Recommended"),
                MenuItem(id: "m139", name: "Sushi Platter for 2", price: 699, isVeg: false, imageName: img(3), description: "12 Sushi + 6 Rolls + Miso Soup + Edamame", menuSection: "Combos"),
            ],
            cuisineText: "Japanese, Sushi, Asian",
            priceForTwo: 800
        ),
        // 25
        Restaurant(
            id: "r25", name: "Waffle House",
            categories: [.all, .desserts, .coffee],
            rating: 4.3, numberOfRatings: 1600,
            deliveryTime: "15-20 mins", distance: "1.5 km",
            offer: "Free Drink on ₹299+",
            imageName: img(3), isPureVeg: true,
            menuItems: [
                MenuItem(id: "m140", name: "Belgian Chocolate Waffle", price: 199, isVeg: true, imageName: img(3), rating: 4.7, numberOfRatings: 780, description: "Crispy waffle drizzled with Belgian chocolate sauce & fresh cream", isBestseller: true, isHighlyOrdered: true, menuSection: "Most Ordered"),
                MenuItem(id: "m141", name: "Nutella Waffle", price: 219, isVeg: true, imageName: img(3), rating: 4.6, numberOfRatings: 560, description: "Warm waffle generously spread with Nutella & crushed hazelnuts", isBestseller: true, menuSection: "Most Ordered"),
                MenuItem(id: "m142", name: "Berry Blast Waffle", price: 229, isVeg: true, imageName: img(3), rating: 4.4, numberOfRatings: 340, description: "Waffle topped with mixed berries, maple syrup & ice cream", menuSection: "Recommended"),
                MenuItem(id: "m143", name: "Classic Pancakes (3 pcs)", price: 149, isVeg: true, imageName: img(3), rating: 4.3, numberOfRatings: 280, description: "Fluffy buttermilk pancakes with maple syrup & butter", menuSection: "Recommended"),
                MenuItem(id: "m144", name: "Hot Chocolate", price: 129, isVeg: true, imageName: img(3), rating: 4.5, numberOfRatings: 230, description: "Rich and creamy Belgian hot chocolate with marshmallows", menuSection: "Drinks"),
                MenuItem(id: "m145", name: "Waffle Party Box", price: 599, isVeg: true, imageName: img(3), description: "3 Waffles + 2 Pancakes + 2 Hot Chocolates", menuSection: "Combos"),
            ],
            cuisineText: "Desserts, Waffles, Pancakes",
            priceForTwo: 400,
            badges: ["Pure Veg", "Top Rated"]
        ),
    ]
    
    // MARK: - Banners
    
    public static let banners: [ZomatoBanner] = [
        ZomatoBanner(title: "ITEMS AT", subtitle: "50% OFF", imageName: "pizza", gradientColors: [Color(red: 0.9, green: 0.1, blue: 0.2), Color(red: 0.8, green: 0.05, blue: 0.15)], badgeText: "Order now"),
        ZomatoBanner(title: "FREE", subtitle: "DELIVERY", imageName: "burger", gradientColors: [Color(red: 0.1, green: 0.6, blue: 0.3), Color(red: 0.05, green: 0.5, blue: 0.25)], badgeText: "No min order"),
        ZomatoBanner(title: "LUNCH", subtitle: "SPECIALS", imageName: "paratha", gradientColors: [Color(red: 0.95, green: 0.6, blue: 0.1), Color(red: 0.85, green: 0.5, blue: 0.05)], badgeText: "Starts ₹99"),
        ZomatoBanner(title: "NEW ON", subtitle: "ZOMATO", imageName: "chillWithCheese", gradientColors: [Color(red: 0.5, green: 0.2, blue: 0.8), Color(red: 0.4, green: 0.1, blue: 0.7)], badgeText: "Explore"),
        ZomatoBanner(title: "FLAT", subtitle: "₹125 OFF", imageName: "pizza", gradientColors: [Color(red: 0.2, green: 0.4, blue: 0.9), Color(red: 0.1, green: 0.3, blue: 0.8)], badgeText: "Use WELCOME"),
        ZomatoBanner(title: "HEALTHY", subtitle: "EATS", imageName: "chillWithCheese", gradientColors: [Color(red: 0.2, green: 0.7, blue: 0.5), Color(red: 0.1, green: 0.6, blue: 0.4)], badgeText: "Under 500 cal"),
        ZomatoBanner(title: "PARTY", subtitle: "PACKS", imageName: "burger", gradientColors: [Color(red: 0.9, green: 0.3, blue: 0.4), Color(red: 0.8, green: 0.2, blue: 0.3)], badgeText: "For 4+ people"),
        ZomatoBanner(title: "LATE NIGHT", subtitle: "CRAVINGS", imageName: "pizza", gradientColors: [Color(red: 0.15, green: 0.15, blue: 0.3), Color(red: 0.1, green: 0.1, blue: 0.25)], badgeText: "Open now"),
    ]
    
    // MARK: - Coupons
    
    public static let coupons: [ZomatoCoupon] = [
        ZomatoCoupon(code: "WELCOME50", title: "50% OFF", description: "50% off up to ₹100 on your first order", discountType: .percentage, discountValue: 50, minOrderAmount: 149, maxDiscount: 100),
        ZomatoCoupon(code: "FLAT100", title: "Flat ₹100 OFF", description: "Flat ₹100 off on orders above ₹299", discountType: .flat, discountValue: 100, minOrderAmount: 299),
        ZomatoCoupon(code: "PARTY20", title: "20% OFF", description: "20% off up to ₹150 on party orders", discountType: .percentage, discountValue: 20, minOrderAmount: 499, maxDiscount: 150),
        ZomatoCoupon(code: "FREEDEL", title: "Free Delivery", description: "Free delivery on orders above ₹149", discountType: .flat, discountValue: 30, minOrderAmount: 149),
        ZomatoCoupon(code: "TREAT75", title: "Flat ₹75 OFF", description: "Flat ₹75 off on orders above ₹249", discountType: .flat, discountValue: 75, minOrderAmount: 249),
        ZomatoCoupon(code: "MEGA30", title: "30% OFF", description: "30% off up to ₹120 on mega orders", discountType: .percentage, discountValue: 30, minOrderAmount: 399, maxDiscount: 120),
        ZomatoCoupon(code: "BOGO", title: "Buy 1 Get 1", description: "Buy 1 Get 1 free on select items above ₹199", discountType: .percentage, discountValue: 50, minOrderAmount: 199, maxDiscount: 200),
        ZomatoCoupon(code: "SAVE50", title: "₹50 OFF", description: "₹50 off on all orders above ₹149", discountType: .flat, discountValue: 50, minOrderAmount: 149),
        ZomatoCoupon(code: "LUNCH25", title: "25% OFF", description: "25% off on lunch orders (11am-3pm)", discountType: .percentage, discountValue: 25, minOrderAmount: 199, maxDiscount: 80),
        ZomatoCoupon(code: "GOLD200", title: "₹200 OFF", description: "Exclusive Gold member discount above ₹599", discountType: .flat, discountValue: 200, minOrderAmount: 599),
    ]
    
    // MARK: - Addresses
    
    public static let addresses: [ZomatoAddress] = [
        ZomatoAddress(label: "Home", fullAddress: "Flat 402, Sunshine Heights, Koramangala 5th Block, Bengaluru 560095", landmark: "Near Sony Signal", isDefault: true, iconName: "house.fill"),
        ZomatoAddress(label: "Work", fullAddress: "WeWork Galaxy, Residency Road, Ashok Nagar, Bengaluru 560025", landmark: "Opposite UB City", isDefault: false, iconName: "building.2.fill"),
        ZomatoAddress(label: "Parents", fullAddress: "B-204, Panchayti Mandir, Subhash Nagar, New Delhi 110027", landmark: "Near Metro Station", isDefault: false, iconName: "house.lodge.fill"),
        ZomatoAddress(label: "Gym", fullAddress: "Gold's Gym, 3rd Floor, Indiranagar 100ft Road, Bengaluru 560038", landmark: "Above Starbucks", isDefault: false, iconName: "figure.run"),
        ZomatoAddress(label: "Friend's Place", fullAddress: "A-101, Prestige Lakeside Habitat, Whitefield, Bengaluru 560066", landmark: "Near ITPL", isDefault: false, iconName: "person.2.fill"),
    ]
    
    // MARK: - Offers
    
    public static let offers: [ZomatoOffer] = [
        ZomatoOffer(title: "50% OFF up to ₹100", description: "Use code WELCOME50", restaurantId: "r1", discountText: "50% OFF"),
        ZomatoOffer(title: "₹50 OFF above ₹199", description: "Auto applied", restaurantId: "r2", discountText: "₹50 OFF"),
        ZomatoOffer(title: "₹100 OFF above ₹199", description: "Use code FLAT100", restaurantId: "r3", discountText: "₹100 OFF"),
        ZomatoOffer(title: "Flat ₹40 OFF", description: "No minimum order", restaurantId: "r4", discountText: "₹40 OFF"),
        ZomatoOffer(title: "20% OFF up to ₹120", description: "Use code SAVE20", restaurantId: "r5", discountText: "20% OFF"),
        ZomatoOffer(title: "₹75 OFF above ₹299", description: "Use code TREAT75", restaurantId: "r6", discountText: "₹75 OFF"),
        ZomatoOffer(title: "Free Delivery", description: "On all orders above ₹149", discountText: "FREE DEL", iconName: "bicycle"),
        ZomatoOffer(title: "₹30 OFF above ₹149", description: "First order on South Indian", restaurantId: "r7", discountText: "₹30 OFF"),
        ZomatoOffer(title: "Buy 1 Get 1 Free", description: "On select rolls", restaurantId: "r8", discountText: "BOGO"),
        ZomatoOffer(title: "Free Dessert", description: "Free brownie on orders above ₹399", restaurantId: "r9", discountText: "FREE"),
        ZomatoOffer(title: "₹80 OFF above ₹349", description: "Italian specials", restaurantId: "r10", discountText: "₹80 OFF"),
        ZomatoOffer(title: "₹60 OFF above ₹249", description: "North Indian feast", restaurantId: "r11", discountText: "₹60 OFF"),
        ZomatoOffer(title: "15% OFF", description: "On healthy bowls", restaurantId: "r12", discountText: "15% OFF"),
        ZomatoOffer(title: "Free Bun Maska", description: "On orders above ₹199", restaurantId: "r13", discountText: "FREE"),
        ZomatoOffer(title: "₹100 OFF above ₹399", description: "Tandoori special", restaurantId: "r14", discountText: "₹100 OFF"),
        ZomatoOffer(title: "₹125 OFF above ₹399", description: "Cheese lovers special", restaurantId: "r15", discountText: "₹125 OFF"),
        ZomatoOffer(title: "₹50 OFF above ₹199", description: "Lucknowi biryani", restaurantId: "r16", discountText: "₹50 OFF"),
        ZomatoOffer(title: "₹150 OFF above ₹499", description: "Pizza party!", restaurantId: "r20", discountText: "₹150 OFF"),
        ZomatoOffer(title: "Flat ₹120 OFF", description: "Royal feast", restaurantId: "r22", discountText: "₹120 OFF"),
        ZomatoOffer(title: "Free Drink", description: "On waffle orders above ₹299", restaurantId: "r25", discountText: "FREE"),
    ]
    
    // MARK: - Past Orders (10)
    
    public static let pastOrders: [ZomatoOrder] = [
        ZomatoOrder(id: "ZMT-834521", items: [], restaurantName: "La Pino'z Pizza", restaurantId: "r1", itemTotal: 408, deliveryFee: 0, taxes: 20, packagingFee: 15, platformFee: 5, tip: 20, donation: 1, couponDiscount: 100, grandTotal: 369, stage: .delivered, orderDate: Date().addingTimeInterval(-86400), estimatedMinutes: 0, deliveryAddress: "Flat 402, Sunshine Heights", paymentMethod: "Google Pay (UPI)", couponCode: "WELCOME50"),
        ZomatoOrder(id: "ZMT-712903", items: [], restaurantName: "Biryani Blues", restaurantId: "r6", itemTotal: 348, deliveryFee: 30, taxes: 17, packagingFee: 15, platformFee: 5, tip: 0, donation: 0, couponDiscount: 75, grandTotal: 340, stage: .delivered, orderDate: Date().addingTimeInterval(-172800), estimatedMinutes: 0, deliveryAddress: "WeWork Galaxy, Residency Road", paymentMethod: "Credit Card", couponCode: "TREAT75"),
        ZomatoOrder(id: "ZMT-598234", items: [], restaurantName: "Dragon Wok", restaurantId: "r5", itemTotal: 338, deliveryFee: 30, taxes: 17, packagingFee: 15, platformFee: 5, tip: 30, donation: 1, couponDiscount: 0, grandTotal: 436, stage: .delivered, orderDate: Date().addingTimeInterval(-259200), estimatedMinutes: 0, paymentMethod: "Paytm Wallet"),
        ZomatoOrder(id: "ZMT-445678", items: [], restaurantName: "Burger Belly", restaurantId: "r4", itemTotal: 308, deliveryFee: 0, taxes: 15, packagingFee: 15, platformFee: 5, tip: 20, donation: 0, couponDiscount: 40, grandTotal: 323, stage: .delivered, orderDate: Date().addingTimeInterval(-345600), estimatedMinutes: 0, paymentMethod: "Cash on Delivery"),
        ZomatoOrder(id: "ZMT-334521", items: [], restaurantName: "Sweet Surrender", restaurantId: "r9", itemTotal: 547, deliveryFee: 0, taxes: 27, packagingFee: 15, platformFee: 5, tip: 50, donation: 1, couponDiscount: 0, grandTotal: 645, stage: .delivered, orderDate: Date().addingTimeInterval(-432000), estimatedMinutes: 0, paymentMethod: "Google Pay (UPI)"),
        ZomatoOrder(id: "ZMT-223456", items: [], restaurantName: "Madras Café", restaurantId: "r7", itemTotal: 228, deliveryFee: 30, taxes: 11, packagingFee: 15, platformFee: 5, tip: 0, donation: 0, couponDiscount: 30, grandTotal: 259, stage: .delivered, orderDate: Date().addingTimeInterval(-518400), estimatedMinutes: 0, paymentMethod: "PhonePe (UPI)"),
        ZomatoOrder(id: "ZMT-112345", items: [], restaurantName: "Desi Dhaba", restaurantId: "r11", itemTotal: 518, deliveryFee: 0, taxes: 26, packagingFee: 15, platformFee: 5, tip: 20, donation: 1, couponDiscount: 60, grandTotal: 525, stage: .delivered, orderDate: Date().addingTimeInterval(-604800), estimatedMinutes: 0, paymentMethod: "Credit Card"),
        ZomatoOrder(id: "ZMT-998877", items: [], restaurantName: "Royal Mughal", restaurantId: "r22", itemTotal: 608, deliveryFee: 30, taxes: 30, packagingFee: 15, platformFee: 5, tip: 30, donation: 0, couponDiscount: 120, grandTotal: 598, stage: .delivered, orderDate: Date().addingTimeInterval(-691200), estimatedMinutes: 0, paymentMethod: "Google Pay (UPI)", couponCode: "GOLD200"),
        ZomatoOrder(id: "ZMT-887766", items: [], restaurantName: "Roll Junction", restaurantId: "r8", itemTotal: 228, deliveryFee: 30, taxes: 11, packagingFee: 15, platformFee: 5, tip: 0, donation: 1, couponDiscount: 0, grandTotal: 290, stage: .delivered, orderDate: Date().addingTimeInterval(-777600), estimatedMinutes: 0, paymentMethod: "Cash on Delivery"),
        ZomatoOrder(id: "ZMT-776655", items: [], restaurantName: "Waffle House", restaurantId: "r25", itemTotal: 418, deliveryFee: 0, taxes: 21, packagingFee: 15, platformFee: 5, tip: 20, donation: 0, couponDiscount: 0, grandTotal: 479, stage: .delivered, orderDate: Date().addingTimeInterval(-864000), estimatedMinutes: 0, paymentMethod: "PhonePe (UPI)"),
    ]
}
