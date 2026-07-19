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
        // 🆕 ETERNAL LITE: Register background tasks for offline order retry and mesh upload.
        // Both identifiers must also appear in BGTaskSchedulerPermittedIdentifiers in Info.plist
        // (trial-Info.plist) — otherwise the OS logs "not advertised in Info.plist" and ignores
        // the registration entirely.

        // 1. Direct offline queue retry (OfflineOrderQueue)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: OfflineOrderQueue.backgroundTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                OfflineOrderQueue.shared.handleBackgroundTask(task)
            }
        }

        // 2. Mesh upload retry (MeshUploadService) — fires when connectivity
        //    returns while the app is backgrounded and there are held packets.
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: MeshUploadService.backgroundTaskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                MeshUploadService.shared.handleBackgroundTask(task)
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
                        // 🆕 MESH RELAY: Request background time to keep MPC session alive
                        // long enough to deliver any held packets before iOS suspends the app.
                        // UIApplication.shared.beginBackgroundTask gives up to 30 seconds.
                        MeshRelayService.shared.beginBackgroundDeliveryTask()
                    } else if newPhase == .active {
                        activityManager.stopCartActivity()
                        MeshRelayService.shared.endBackgroundDeliveryTask()
                    }
                })
        }
    }
}

