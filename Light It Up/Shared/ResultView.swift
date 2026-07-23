import SwiftUI

struct ResultView: View {
    let gameMode: GameMode
    let score: Int
    let highScore: Int
    let newHighScore: Bool
    
    let onRestart: () -> Void
    let onExit: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var highlightColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
    // Generates the customized text to share with friends
    var shareMessage: String {
        "I just scored \(score) on \(gameMode.rawValue) — beat that!"
    }
    
    // Load score history for the active user in the current game mode (limit to latest 10)
    private var personalScoreHistory: [GameSession] {
        let allSessions = GameSessionStore.loadSessions()
        let activeUser = UserDefaults.standard.string(forKey: "PlayerDisplayName") ?? "Guest"
        
        let filtered = allSessions.filter { session in
            session.mode == gameMode && (session.username == activeUser)
        }
        .sorted { $0.timestamp > $1.timestamp } // Sort by newest first
        
        return Array(filtered.prefix(10))
    }
    
    private var activeUser: String {
        UserDefaults.standard.string(forKey: "PlayerDisplayName") ?? "Guest"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            baseBackgroundColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header Title
                    VStack(spacing: 8) {
                        Text(newHighScore ? "NEW RECORD!" : "GAME OVER")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(newHighScore ? highlightColor : .accentColor)
                            .tracking(3)
                            .shadow(color: (newHighScore ? highlightColor : Color.accentColor).opacity(colorScheme == .light ? 0.25 : 0.5), radius: 8)
                        
                        Text("Thanks for playing Game Arcadia")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)
                    
                    // Score Badges side-by-side
                    HStack(spacing: 20) {
                        ScoreBadge(title: "Your Score", score: score, color: .accentColor)
                        ScoreBadge(title: "Best Score", score: highScore, color: highlightColor)
                    }
                    
                    // Personal Score History
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(activeUser.uppercased())'S PLAY HISTORY (LATEST 10)")
                            .font(.system(size: 11, weight: .bold).monospaced())
                            .foregroundColor(highlightColor)
                            .padding(.horizontal, 4)
                        
                        if personalScoreHistory.isEmpty {
                            Text("No past scores recorded for this mode.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                                .background(colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05), lineWidth: 1)
                                )
                        } else {
                            VStack(spacing: 10) {
                                ForEach(Array(personalScoreHistory.enumerated()), id: \.element.id) { index, session in
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill((session.score >= highScore && session.score > 0) ? highlightColor.opacity(0.12) : Color.accentColor.opacity(0.08))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: (session.score >= highScore && session.score > 0) ? "crown.fill" : "medal.fill")
                                                .font(.subheadline)
                                                .foregroundColor((session.score >= highScore && session.score > 0) ? highlightColor : .accentColor)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formatDate(session.timestamp))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(session.score) pts")
                                            .font(.system(.body, design: .monospaced).bold())
                                            .foregroundColor((session.score >= highScore && session.score > 0) ? highlightColor : .primary)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background((session.score >= highScore && session.score > 0) ? highlightColor.opacity(0.08) : Color.primary.opacity(0.04))
                                            .cornerRadius(8)
                                    }
                                    .padding()
                                    .background(colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
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
                    .padding(.horizontal, 20)
                    
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
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.06))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    ResultView(
        gameMode: .tapFrenzyDefault,
        score: 42,
        highScore: 80,
        newHighScore: true,
        onRestart: {},
        onExit: {}
    )
}
