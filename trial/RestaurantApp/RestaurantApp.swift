//
//  RestaurantApp.swift
//  RestaurantApp — Eternal Lite Demo
//
//  This is the SECOND app in the two-device demo.
//  Install on iPhone B (the "restaurant" device).
//  It listens over Bluetooth/peer Wi-Fi for incoming OrderPackets from
//  the customer app, shows a beautiful order card, plays haptic + sound,
//  and immediately sends a signed acknowledgment back to the customer.
//
//  NO INTERNET REQUIRED — the entire flow works on Bluetooth alone.
//

import SwiftUI

@main
struct RestaurantApp: App {

    @StateObject private var receiver = RestaurantMeshReceiver.shared

    var body: some Scene {
        WindowGroup {
            RestaurantRootView()
                .environmentObject(receiver)
        }
    }
}
