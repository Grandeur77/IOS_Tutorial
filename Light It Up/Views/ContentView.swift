import SwiftUI

struct ContentView: View {
    @State private var selection: GameType? = nil
    @State private var showHighScores = false
    
    // High Score tracking to display on the cards
    @AppStorage("LightItUpHighScore") private var lightItUpScore: Int = 0
    @AppStorage("QuizRushHighScore") private var quizRushScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Default") private var tfDefaultScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Combo System") private var tfComboScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Trap Colour") private var tfTrapScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Moving Target") private var tfMovingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Shrinking Button") private var tfShrinkingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Bonus Burst") private var tfBurstScore: Int = 0
    
    // Calculates highest score
    var highestTapFrenzyScore: Int {
        max(tfDefaultScore, tfComboScore, tfTrapScore, tfMovingScore, tfShrinkingScore, tfBurstScore)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {

                    VStack(spacing: 8) {
                        Text("GAME ARCADIA")
                            .font(.system(size: 36, weight: .black, design: .monospaced))
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
                            .font(.system(size: 17, weight: .bold).monospaced())
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    Spacer() // Pushes the buttons group into the vertical center
                    
                    // Game Selection Cards (Centered group with 40pt spacing)
                    VStack(spacing: 40) {
                        
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
                    .padding(.horizontal)
                    
                    Spacer() // Pushes the buttons group into the vertical center
                    
                    // Compact Circular Trophy Button Only
                    Button(action: {
                        showHighScores = true
                    }) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 70, height: 70)
                            .background(Color.yellow)
                            .clipShape(Circle())
                            .shadow(color: .yellow.opacity(0.4), radius: 8)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: Binding(get: { selection == .lightItUp }, set: { if !$0 { selection = nil } })) {
                LightItUpView()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .tapFrenzy }, set: { if !$0 { selection = nil } })) {
                TapFrenzyView()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .quizRush }, set: { if !$0 { selection = nil } })) {
                QuizRushView()
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresSheet()
            }
        }
    }
}

// Game Card Component
struct GameCard: View {
    let title: String
    let description: String
    let iconName: String
    let highScore: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Colored Icon Frame
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
                
                // Game Info
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
                
                // Score Badge
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
                    .strokeBorder(Color.white, lineWidth: 2)
            )
        }
    }
}

// High Scores Sheet View
struct HighScoresSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("LightItUpHighScore") private var lightItUpScore: Int = 0
    @AppStorage("QuizRushHighScore") private var quizRushScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Default") private var tfDefaultScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Combo System") private var tfComboScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Trap Colour") private var tfTrapScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Moving Target") private var tfMovingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Shrinking Button") private var tfShrinkingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Bonus Burst") private var tfBurstScore: Int = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("High Score History")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Light It Up")
                            .font(.title2.bold())
                            .foregroundColor(.accentColor)
                        
                        HStack {
                            Text("Best Score")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(lightItUpScore)")
                                .font(.title3.bold())
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        Divider().background(Color.gray)
                        
                        Text("Quiz Rush")
                            .font(.title2.bold())
                            .foregroundColor(.accentColor)
                        
                        HStack {
                            Text("Best Score")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(quizRushScore)")
                                .font(.title3.bold())
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        Divider().background(Color.gray)
                        
                        Text("Tap Frenzy Modes")
                            .font(.title2.bold())
                            .foregroundColor(.accentColor)
                        
                        let modes = [
                            ("Default", tfDefaultScore),
                            ("Combo System", tfComboScore),
                            ("Trap Colour", tfTrapScore),
                            ("Moving Target", tfMovingScore),
                            ("Shrinking Button", tfShrinkingScore),
                            ("Bonus Burst", tfBurstScore)
                        ]
                        
                        VStack(spacing: 12) {
                            ForEach(modes, id: \.0) { name, score in
                                  HStack {
                                      Text(name)
                                          .foregroundColor(.white)
                                      Spacer()
                                      Text("\(score)")
                                          .font(.headline)
                                          .foregroundColor(.yellow)
                                  }
                                  .padding()
                                  .background(Color.gray.opacity(0.15))
                                  .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                
                Button("Dismiss") {
                    dismiss()
                }
                .font(.title3.bold())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundColor(.black)
                .clipShape(Capsule())
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ContentView()
}
