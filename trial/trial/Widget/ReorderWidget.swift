//
//  ReorderWidget.swift
//  BlinkitFlow
//
//  DEMO: WidgetKit home screen widget UI component.
//

import WidgetKit
import SwiftUI

public struct ReorderWidgetEntry: TimelineEntry {
    public let date: Date
    public let lastOrderTitle: String
    public let itemCount: Int
}

public struct ReorderWidgetView: View {
    public let entry: ReorderWidgetEntry
    
    public init(entry: ReorderWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(BlinkitTheme.yellow)
                Text("Blinkit Express")
                    .font(.system(size: 12, weight: .black))
                Spacer()
            }
            
            Text("Reorder Usual")
                .font(.system(size: 14, weight: .bold))
            
            Text("\(entry.lastOrderTitle) (\(entry.itemCount) items)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            Link(destination: URL(string: "blinkit://reorder/last")!) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("1-Tap Reorder")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(BlinkitTheme.brandGreen)
                .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color(uiColor: .systemBackground))
    }
}
