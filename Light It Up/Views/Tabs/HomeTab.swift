import SwiftUI

struct HomeTab: View {
    @State private var selection: GameType? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var titleColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
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
                baseBackgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 12) {
                        Text("GAME ARCADIA")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(titleColor)
                            .tracking(6)
                            .shadow(color: titleColor.opacity(colorScheme == .light ? 0.2 : 0.5), radius: 10)
                        
                        Text("SELECT A CHALLENGE TO BEGIN")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(colorScheme == .light ? .secondary : .gray)
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
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var cardBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
    private var themeColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(themeColor)
                    .frame(width: 50, height: 50)
                    .background(themeColor.opacity(0.1))
                    .cornerRadius(12)
                    .shadow(color: themeColor.opacity(0.2), radius: 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title.uppercased())
                        .font(.system(.headline, design: .monospaced).bold())
                        .foregroundColor(.primary)
                        .tracking(1)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            .background(cardBackgroundColor)
            .cornerRadius(20)
            
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: colorScheme == .light
                                ? [Color.black.opacity(0.06), Color.black.opacity(0.04)]
                                : [.accentColor.opacity(0.4), themeColor.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: colorScheme == .light ? Color.black.opacity(0.03) : Color.accentColor.opacity(0.15), radius: 6)
            )
        }
    }
}
