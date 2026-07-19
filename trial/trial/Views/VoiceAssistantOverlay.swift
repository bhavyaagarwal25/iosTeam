//
//  VoiceAssistantOverlay.swift
//  BlinkitFlow
//

import SwiftUI

public struct VoiceAssistantOverlay: View {
    @Binding var isPresented: Bool
    @State private var isListening = false
    @State private var transcribedText = "Listening..."
    @State private var hasProcessed = false
    
    let cartService = CartService.shared
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text(transcribedText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .animation(.easeInOut, value: transcribedText)
                
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(isListening ? 0.2 : 0.0))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isListening ? 1.5 : 1.0)
                        .animation(isListening ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isListening)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.2), radius: 20)
        }
        .onAppear {
            startSimulation()
        }
    }
    
    private func startSimulation() {
        isListening = true
        transcribedText = "Listening..."
        
        // Simulate Siri thinking...
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            transcribedText = "Add milk, bread, and eggs"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isListening = false
                processCommand()
            }
        }
    }
    
    private func processCommand() {
        if hasProcessed { return }
        hasProcessed = true
        
        // Find milk, bread, eggs in MockData
        let itemsToAdd = ["milk", "bread", "eggs"]
        var addedCount = 0
        
        for itemName in itemsToAdd {
            if let product = MockData.sampleProducts.first(where: { $0.name.lowercased() == itemName }) {
                cartService.addToCart(product: product)
                addedCount += 1
            }
        }
        
        transcribedText = "Added \(addedCount) items to cart!"
        BlinkitTheme.triggerNotificationHaptic(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPresented = false
        }
    }
}
