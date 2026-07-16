import SwiftUI

struct ResultView: View {
    let gameModeName: String
    let score: Int
    let highScore: Int
    let newHighScore: Bool
    
    let onRestart: () -> Void
    let onExit: () -> Void
    
    // Generates the customized text to share with friends
    var shareMessage: String {
        "I just scored \(score) on \(gameModeName) — beat that!"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header Title
                VStack(spacing: 8) {
                    Text(newHighScore ? "NEW RECORD!" : "GAME OVER")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(newHighScore ? .yellow : .accentColor)
                        .tracking(3)
                        .shadow(color: (newHighScore ? Color.yellow : Color.accentColor).opacity(0.5), radius: 8)
                    
                    Text("Thanks for playing Game Arcadia")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Score Badges side-by-side
                HStack(spacing: 20) {
                    ScoreBadge(title: "Your Score", score: score, color: .accentColor)
                    ScoreBadge(title: "Best Score", score: highScore, color: .yellow)
                }
                
                Spacer()
                
                // SwiftUI Native ShareLink
                ShareLink(item: shareMessage) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Your Score")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(12)
                    .shadow(color: .yellow.opacity(0.3), radius: 6)
                }
                .padding(.horizontal)
                
                // Control Buttons
                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onExit) {
                        Text("Back to Hub")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ResultView(
        gameModeName: "Tap Frenzy",
        score: 42,
        highScore: 80,
        newHighScore: true,
        onRestart: {},
        onExit: {}
    )
}
