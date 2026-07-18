//
//  AmbulanceView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct AmbulanceView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Emergency Ambulance")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Blinkit Emergency Services - Coming Soon")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Ambulance")
        }
    }
}

#Preview {
    AmbulanceView()
}
