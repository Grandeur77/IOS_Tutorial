import SwiftUI

struct ContentView: View {
    @State private var selection: GameType? = nil
    @State private var showHighScores = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 40) {
                    Text("Mini Game Hub")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Button("Light It Up") {
                        selection = .lightItUp
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                    
                    Button("Tap Frenzy") {
                        selection = .tapFrenzy
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                    
                    Button("Quiz Rush") {
                        selection = .quizRush
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                    
                    Button("High Scores") {
                        showHighScores = true
                    }
                    .font(.title3.bold())
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .foregroundColor(.accentColor)
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
                .foregroundColor(.white)
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
