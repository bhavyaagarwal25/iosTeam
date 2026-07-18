//
//  OrderLiveActivityWidget.swift
//  BlinkitFlow
//
//  DEMO: Live Activity & Dynamic Island UI layout elements for Cart & Orders.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct OrderLiveActivityWidget: Widget {
    public init() {}
    
    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: BlinkitActivityAttributes.self) { context in
            // Lock Screen Banner
            VStack(spacing: 10) {
                if context.state.isCart {
                    // CART UI
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(BlinkitTheme.brandGreen)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Cart is ready")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(context.state.cartItemCount ?? 0) items • ₹\(Int(context.state.cartTotalAmount ?? 0))")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Text("Checkout")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(BlinkitTheme.brandGreen.opacity(0.2))
                            .clipShape(Capsule())
                    }
                } else {
                    // ORDER UI
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(BlinkitTheme.yellow)
                            Text("BLINKIT EXPRESS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("ETA \(context.state.etaMinutes ?? 0) MINS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(BlinkitTheme.yellow)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 24))
                            .foregroundColor(BlinkitTheme.brandGreen)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.stageName ?? "Processing")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("Rider: \(context.state.riderName ?? "Pending") • Order \(context.attributes.activityId.prefix(8))")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    ProgressView(value: context.state.progress ?? 0.0)
                        .tint(BlinkitTheme.brandGreen)
                }
            }
            .padding(16)
            .background(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    if context.state.isCart {
                        Image(systemName: "cart.fill")
                            .font(.title2)
                            .foregroundColor(BlinkitTheme.brandGreen)
                            .padding(.leading, 8)
                    } else {
                        Text("blinkit.")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                            .padding(.top, 4)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isCart {
                        Text("₹\(Int(context.state.cartTotalAmount ?? 0))")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(BlinkitTheme.brandGreen)
                            .padding(.trailing, 8)
                    } else {
                        // Empty trailing in expanded view
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isCart {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ready to checkout?")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("You have \(context.state.cartItemCount ?? 0) items in your cart.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Order arrives in \(context.state.etaMinutes ?? 0) min")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 4) {
                                        Text("To")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(Color.orange)
                                            .font(.system(size: 13))
                                        Text(context.attributes.deliveryAddress ?? "Flat 402, Sunshine Heights")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                Image(systemName: "scooter")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color(white: 0.3))
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(context.state.riderName ?? "Pending")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Driver • ★ 5.0")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 36, height: 36)
                                        .overlay(Image(systemName: "phone.fill").font(.system(size: 16)).foregroundColor(.white))
                                    
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 36, height: 36)
                                        .overlay(Image(systemName: "envelope.fill").font(.system(size: 16)).foregroundColor(.white))
                                }
                            }
                        }
                        .padding(.top, 4)
                        .padding(.horizontal, 4)
                    }
                }
            } compactLeading: {
                if context.state.isCart {
                    Image(systemName: "cart.fill")
                        .foregroundColor(BlinkitTheme.brandGreen)
                } else {
                        HStack {
                            Image(systemName: "scooter")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    }
            } compactTrailing: {
                if context.state.isCart {
                    Text("₹\(Int(context.state.cartTotalAmount ?? 0))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(BlinkitTheme.brandGreen)
                } else {
                    Text("\(context.state.etaMinutes ?? 0) min")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.trailing, 4)
                }
            } minimal: {
                if context.state.isCart {
                    Image(systemName: "cart.fill")
                        .foregroundColor(BlinkitTheme.brandGreen)
                } else {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(BlinkitTheme.yellow)
                }
            }
        }
    }
}
