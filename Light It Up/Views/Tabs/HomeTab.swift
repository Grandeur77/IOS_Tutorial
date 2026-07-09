import SwiftUI

struct HomeTab: View {
    @State private var selection: GameType? = nil
    
    // 1. Read high scores for Light It Up
    @AppStorage("LightItUpHighScore") private var lightItUpScore: Int = 0
    
    // 2. Read high scores for all Tap Frenzy sub-modes
    @AppStorage("TapFrenzyHighScore_Default") private var tfDefaultScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Combo System") private var tfComboScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Trap Colour") private var tfTrapScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Moving Target") private var tfMovingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Shrinking Button") private var tfShrinkingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Bonus Burst") private var tfBurstScore: Int = 0
    
    // Calculates highest score across all Tap Frenzy sub-modes to display on the card
    var highestTapFrenzyScore: Int {
        max(tfDefaultScore, tfComboScore, tfTrapScore, tfMovingScore, tfShrinkingScore, tfBurstScore)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("GAME ARCADIA")
                            .font(.system(size: 34, weight: .black, design: .monospaced))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentColor, .white],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .accentColor.opacity(0.8), radius: 10)
                            .tracking(4)
                        
                        Text("Select a challenge to begin")
                            .font(.system(size: 10, weight: .bold).monospaced())
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Buttons container
                    VStack(spacing: 40) {
                        GameCard(
                            title: "Light It Up",
                            description: "Reflex game. Tap before it goes dark.",
                            iconName: "lightbulb.fill",
                            highScore: lightItUpScore
                        ) {
                            selection = .lightItUp
                        }
                        
                        // <-- Added Tap Frenzy Game Card
                        GameCard(
                            title: "Tap Frenzy",
                            description: "Speed game. Smash the buttons fast.",
                            iconName: "hand.tap.fill",
                            highScore: highestTapFrenzyScore
                        ) {
                            selection = .tapFrenzy
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: Binding(get: { selection == .lightItUp }, set: { if !$0 { selection = nil } })) {
                LightItUpView()
            }
            // <-- Added Tap Frenzy Navigation Destination
            .navigationDestination(isPresented: Binding(get: { selection == .tapFrenzy }, set: { if !$0 { selection = nil } })) {
                TapFrenzyView()
            }
        }
    }
}

// MARK: - Game Card Component
struct GameCard: View {
    let title: String
    let description: String
    let iconName: String
    let highScore: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.12))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("HI-SCORE")
                        .font(.system(size: 8, weight: .bold).monospaced())
                        .foregroundColor(.yellow.opacity(0.7))
                    Text("\(highScore)")
                        .font(.subheadline.bold().monospacedDigit())
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.08))
                .cornerRadius(6)
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.accentColor.opacity(0.5))
            }
            .padding()
            .frame(height: 80)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
            )
        }
    }
}
