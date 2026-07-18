//
//  OrderLiveActivityWidget.swift
//  BlinkitFlow
//
//  DEMO: Live Activity & Dynamic Island UI layout elements.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct OrderLiveActivityWidget: Widget {
    public init() {}
    
    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            // Lock Screen Banner
            VStack(spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(BlinkitTheme.yellow)
                        Text("BLINKIT EXPRESS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("ETA \(context.state.etaMinutes) MINS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BlinkitTheme.yellow)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 24))
                        .foregroundColor(BlinkitTheme.brandGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.stageName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Rider: \(context.state.riderName) • Order \(context.attributes.orderId)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                ProgressView(value: context.state.progress)
                    .tint(BlinkitTheme.brandGreen)
            }
            .padding(16)
            .background(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(BlinkitTheme.yellow)
                        Text("Blinkit")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.etaMinutes)m ETA")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(BlinkitTheme.yellow)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(context.state.stageName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Delivery Rider: \(context.state.riderName)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            } compactLeading: {
                Image(systemName: "bolt.fill")
                    .foregroundColor(BlinkitTheme.yellow)
            } compactTrailing: {
                Text("\(context.state.etaMinutes)m")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(BlinkitTheme.yellow)
            } minimal: {
                Image(systemName: "bolt.fill")
                    .foregroundColor(BlinkitTheme.yellow)
            }
        }
    }
}
