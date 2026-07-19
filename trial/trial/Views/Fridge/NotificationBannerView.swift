//
//  NotificationBannerView.swift
//  BlinkitFlow
//

import SwiftUI

public struct NotificationBannerView: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var offset: CGFloat = -150
    
    public var body: some View {
        Button(action: {
            BlinkitTheme.triggerNotificationHaptic(.success)
            withAnimation(.spring()) {
                offset = -150
            }
            action()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "snowflake")
                        .foregroundColor(.blue)
                        .font(.system(size: 24, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                offset = 16
            }
            
            // Auto dismiss after 6 seconds if not tapped
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.spring()) {
                    offset = -150
                }
            }
        }
    }
}
