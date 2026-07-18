//
//  HandCricketView.swift
//  BlinkitFlow
//
//  Mini game shown while waiting for order delivery.
//

import SwiftUI

public struct HandCricketView: View {
    public let opponentName: String
    public let onDismiss: () -> Void
    
    @State private var playerScore: Int = 0
    @State private var opponentScore: Int = 0
    @State private var playerChoice: Int? = nil
    @State private var opponentChoice: Int? = nil
    @State private var round: Int = 1
    @State private var gameOver: Bool = false
    @State private var resultMessage: String = ""
    
    public init(opponentName: String, onDismiss: @escaping () -> Void) {
        self.opponentName = opponentName
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("✋ Hand Cricket")
                    .font(.system(size: 28, weight: .black))
                
                HStack(spacing: 40) {
                    scoreBox(label: "You", score: playerScore)
                    Text("VS").font(.system(size: 18, weight: .bold)).foregroundColor(.secondary)
                    scoreBox(label: opponentName, score: opponentScore)
                }
                
                if gameOver {
                    Text(resultMessage)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(BlinkitTheme.brandGreen)
                        .padding()
                    
                    Button("Play Again") {
                        resetGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BlinkitTheme.brandGreen)
                } else {
                    Text("Round \(round) — Pick a number:")
                        .font(.system(size: 16, weight: .semibold))
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 12) {
                        ForEach(1...6, id: \.self) { num in
                            Button("\(num)") {
                                playRound(playerPick: num)
                            }
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 70, height: 70)
                            .background(BlinkitTheme.brandGreenLight)
                            .cornerRadius(14)
                            .foregroundColor(BlinkitTheme.brandGreen)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let pc = playerChoice, let oc = opponentChoice {
                        Text("You: \(pc)  •  \(opponentName): \(oc)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { onDismiss() }
                }
            }
        }
    }
    
    private func scoreBox(label: String, score: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(BlinkitTheme.brandGreen)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private func playRound(playerPick: Int) {
        let opponentPick = Int.random(in: 1...6)
        playerChoice = playerPick
        opponentChoice = opponentPick
        
        if playerPick == opponentPick {
            // Out — opponent scores
            opponentScore += playerPick
        } else {
            playerScore += playerPick
        }
        
        round += 1
        if round > 5 {
            endGame()
        }
    }
    
    private func endGame() {
        gameOver = true
        if playerScore > opponentScore {
            resultMessage = "🎉 You Win! \(playerScore) - \(opponentScore)"
        } else if opponentScore > playerScore {
            resultMessage = "😔 \(opponentName) Wins! \(opponentScore) - \(playerScore)"
        } else {
            resultMessage = "🤝 It's a Tie! \(playerScore) - \(opponentScore)"
        }
    }
    
    private func resetGame() {
        playerScore = 0
        opponentScore = 0
        round = 1
        playerChoice = nil
        opponentChoice = nil
        gameOver = false
        resultMessage = ""
    }
}
