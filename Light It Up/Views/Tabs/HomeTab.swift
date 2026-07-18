import SwiftUI

struct HomeTab: View {
    @State private var selection: GameType? = nil
    
    // Read high scores for all Tap Frenzy sub-modes
    @AppStorage("TapFrenzyHighScore_Default") private var tfDefaultScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Combo System") private var tfComboScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Trap Colour") private var tfTrapScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Moving Target") private var tfMovingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Shrinking Button") private var tfShrinkingScore: Int = 0
    @AppStorage("AppStorageKeyForTapFrenzyHighScore_Bonus Burst") private var tfBurstScore: Int = 0
    
    // Calculates highest score across Tap Frenzy
    var highestTapFrenzyScore: Int {
        max(tfDefaultScore, tfComboScore, tfTrapScore, tfMovingScore, tfShrinkingScore, tfBurstScore)
    }
    
    // Read high scores for other modes
    @AppStorage("LightItUpHighScore") private var lightItUpScore: Int = 0
    @AppStorage("QuizRushHighScore") private var quizRushScore: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {

                    VStack(spacing: 12) {
                        Text("GAME ARCADIA")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                            .tracking(6)
                            .shadow(color: Color.yellow.opacity(0.5), radius: 10)
                        
                        Text("SELECT A CHALLENGE TO BEGIN")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(2)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        GameCard(
                            title: "Tap Frenzy",
                            description: "Speed game. Smash the buttons fast.",
                            iconName: "hand.tap.fill",
                            highScore: highestTapFrenzyScore
                        ) {
                            selection = .tapFrenzy
                        }
                        
                        GameCard(
                            title: "Light It Up",
                            description: "Reflex game. Tap before it goes dark.",
                            iconName: "lightbulb.fill",
                            highScore: lightItUpScore
                        ) {
                            selection = .lightItUp
                        }
                        
                        GameCard(
                            title: "Quiz Rush",
                            description: "Trivia game. Answer under pressure.",
                            iconName: "questionmark.circle.fill",
                            highScore: quizRushScore
                        ) {
                            selection = .quizRush
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: Binding(get: { selection == .tapFrenzy }, set: { if !$0 { selection = nil } })) {
                TapFrenzyView()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .lightItUp }, set: { if !$0 { selection = nil } })) {
                LightItUpView()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .quizRush }, set: { if !$0 { selection = nil } })) {
                QuizRushView()
            }
        }
    }
}

// Beautiful Glassmorphic Game Select Card Component
struct GameCard: View {
    let title: String
    let description: String
    let iconName: String
    let highScore: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {

                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .frame(width: 50, height: 50)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                    .shadow(color: .yellow.opacity(0.2), radius: 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title.uppercased())
                        .font(.system(.headline, design: .monospaced).bold())
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // High Score badge
                VStack(alignment: .trailing, spacing: 4) {
                    Text("HI-SCORE")
                        .font(.system(size: 8, weight: .bold).monospaced())
                        .foregroundColor(.accentColor.opacity(0.8))
                    Text("\(highScore)")
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
                )
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.03), Color.white.opacity(0.01)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            ) // Glass backdrop
            .cornerRadius(20)
      
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.accentColor.opacity(0.4), .yellow.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .accentColor.opacity(0.15), radius: 6)
            )
        }
    }
}
