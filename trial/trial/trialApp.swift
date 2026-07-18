//
//  trialApp.swift
//  BlinkitFlow
//

import SwiftUI

@main
struct trialApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase, perform: { newPhase in
                    let cart = CartService.shared
                    let activityManager = LiveActivityManager.shared
                    
                    if newPhase == .background || newPhase == .inactive {
                        if cart.totalItemCount > 0 {
                            activityManager.startCartActivity(itemCount: cart.totalItemCount, totalAmount: cart.grandTotal)
                        }
                    } else if newPhase == .active {
                        activityManager.stopCartActivity()
                    }
                })
        }
    }
}
