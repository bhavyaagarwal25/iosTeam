//
//  trialApp.swift
//  BlinkitFlow + Eternal Lite
//
//  ETERNAL LITE: Registers BackgroundTasks for offline order retry.
//  Apple API: BackgroundTasks framework → BGTaskScheduler
//

import SwiftUI
import BackgroundTasks

@main
struct trialApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // 🆕 ETERNAL LITE: Register background task for offline order retry
        // Apple API: BGTaskScheduler — allows the app to process queued orders
        // even when the user has backgrounded the app.
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: OfflineOrderQueue.backgroundTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                OfflineOrderQueue.shared.handleBackgroundTask(task)
            }
        }
    }
    
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

