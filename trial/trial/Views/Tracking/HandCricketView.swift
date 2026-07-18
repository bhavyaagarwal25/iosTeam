//
//  HandCricketView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct HandCricketView: View {
    let opponentName: String
    let onExit: () -> Void
    
    // Game State
    @State private var userRuns: Int = 0
    @State private var opponentRuns: Int = 0
    @State private var userIsBatting: Bool = true // User bats first for simplicity
    @State private var currentInning: Int = 1 // 1 or 2
    @State private var gameOver: Bool = false
    @State private var matchResult: String = ""
    
    // Current Turn State
    @State private var userChoice: Int? = nil
    @State private var opponentChoice: Int? = nil
    @State private var statusMessage: String = "You are batting now"
    
    public init(opponentName: String, onExit: @escaping () -> Void) {
        self.opponentName = opponentName
        self.onExit = onExit
    }
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 0.9), Color(red: 0.6, green: 0.8, blue: 0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Exit Button
                HStack {
                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Header Scoreboard
                scoreboardView
                
                Spacer()
                
                // Play Area (Hands)
                playAreaView
                
                Spacer()
                
                // Status and Keypad
                VStack(spacing: 16) {
                    Text(statusMessage)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(20)
                    
                    if gameOver {
                        Button(action: resetGame) {
                            Text("Play Again")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        keypadView
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var scoreboardView: some View {
        HStack {
            // User Score
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                        .overlay(Text("Me").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                    Text("Gul")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if userIsBatting {
                        Image(systemName: "cricket.ball.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                }
                Text("\(userRuns) runs")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue.opacity(0.6))
            .cornerRadius(12)
            
            Spacer()
            
            // Opponent Score
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    if !userIsBatting {
                        Image(systemName: "cricket.ball.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                    Spacer()
                    Text(opponentName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                        .overlay(Text(String(opponentName.prefix(1))).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                }
                Text("\(opponentRuns) runs")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.red.opacity(0.6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var playAreaView: some View {
        HStack {
            // User Hand
            VStack {
                Text(emojiForChoice(userChoice))
                    .font(.system(size: 100))
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // Flip for left side
            }
            Spacer()
            // Opponent Hand
            VStack {
                Text(emojiForChoice(opponentChoice))
                    .font(.system(size: 100))
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var keypadView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                keypadButton(number: 1)
                keypadButton(number: 2)
                keypadButton(number: 3)
            }
            HStack(spacing: 12) {
                keypadButton(number: 4)
                keypadButton(number: 5)
                keypadButton(number: 6)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func keypadButton(number: Int) -> some View {
        Button(action: {
            playTurn(userChoice: number)
        }) {
            Text("\(number)")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
        }
    }
    
    // MARK: - Game Logic
    
    private func emojiForChoice(_ choice: Int?) -> String {
        switch choice {
        case 1: return "☝️"
        case 2: return "✌️"
        case 3: return "🤟"
        case 4: return "🖖"
        case 5: return "🖐️"
        case 6: return "👍"
        default: return "✊" // Waiting
        }
    }
    
    private func playTurn(userChoice: Int) {
        let opponentChoice = Int.random(in: 1...6)
        self.userChoice = userChoice
        self.opponentChoice = opponentChoice
        
        if userChoice == opponentChoice {
            // WICKET!
            if currentInning == 1 {
                // Switch innings
                currentInning = 2
                userIsBatting.toggle()
                statusMessage = "OUT! \(userIsBatting ? "You are" : "\(opponentName) is") batting now."
            } else {
                // Match Over
                gameOver = true
                determineWinner()
            }
        } else {
            // RUNS SCORED
            if userIsBatting {
                userRuns += userChoice
            } else {
                opponentRuns += opponentChoice
            }
            statusMessage = "\(userIsBatting ? "You" : opponentName) scored \(userIsBatting ? userChoice : opponentChoice) runs!"
            
            // Check if second inning and target chased
            if currentInning == 2 {
                if userIsBatting && userRuns > opponentRuns {
                    gameOver = true
                    determineWinner()
                } else if !userIsBatting && opponentRuns > userRuns {
                    gameOver = true
                    determineWinner()
                }
            }
        }
    }
    
    private func determineWinner() {
        if userRuns > opponentRuns {
            statusMessage = "🎉 YOU WON!"
        } else if opponentRuns > userRuns {
            statusMessage = "😔 \(opponentName) WON!"
        } else {
            statusMessage = "🤝 MATCH DRAWN!"
        }
    }
    
    private func resetGame() {
        userRuns = 0
        opponentRuns = 0
        userIsBatting = true
        currentInning = 1
        gameOver = false
        userChoice = nil
        opponentChoice = nil
        statusMessage = "You are batting now"
    }
}
