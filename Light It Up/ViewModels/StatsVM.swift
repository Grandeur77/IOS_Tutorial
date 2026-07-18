import SwiftUI
import Combine

struct GameDistribution: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

// Leaderboard Entry Model
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let username: String
    let score: Int
}

class StatsVM: ObservableObject {
    // reload changes automatically
    @Published var sessions: [GameSession] = []
    
    // reloads the sessions from GameSessionStore
    func refresh() {
        self.sessions = GameSessionStore.loadSessions()
    }
    
    // total played game count
    var totalGamesPlayed: Int {
        sessions.count
    }
    
    // avg score calculation
    var averageScore: Double {
        guard !sessions.isEmpty else { return 0.0 }
        let sum = sessions.reduce(0) { $0 + $1.score }
        return Double(sum) / Double(sessions.count)
    }
    
    // high score calculation
    func personalBest(for mode: GameMode) -> Int {
        let modeSessions = sessions.filter { $0.mode == mode }
        return modeSessions.map { $0.score }.max() ?? 0
    }
    
    // recently played games
    var recentSessions: [GameSession] {
        Array(sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5))
    }
    
    // game distribution
    var gameDistribution: [GameDistribution] {
        let lightItUpCount = sessions.filter { $0.mode == .lightItUp }.count
        let quizRushCount = sessions.filter { $0.mode == .quizRush }.count
        let tapFrenzyCount = sessions.filter { $0.mode.rawValue.contains("Tap Frenzy") }.count
        
        var distribution: [GameDistribution] = []
        if lightItUpCount > 0 {
            distribution.append(GameDistribution(name: "Light It Up", count: lightItUpCount))
        }
        if quizRushCount > 0 {
            distribution.append(GameDistribution(name: "Quiz Rush", count: quizRushCount))
        }
        if tapFrenzyCount > 0 {
            distribution.append(GameDistribution(name: "Tap Frenzy", count: tapFrenzyCount))
        }
        return distribution
    }
    
    // player leaderboard scores
    func leaderboard(for category: GameModeCategory) -> [LeaderboardEntry] {
        let filtered: [GameSession]
        switch category {
        case .tapFrenzy:
            filtered = sessions.filter { $0.mode.rawValue.contains("Tap Frenzy") }
        case .lightItUp:
            filtered = sessions.filter { $0.mode == .lightItUp }
        case .quizRush:
            filtered = sessions.filter { $0.mode == .quizRush }
        }
        
        // Group by username and find the maximum score achieved by each player
        var userBests: [String: Int] = [:]
        for session in filtered {
            let name = session.username ?? "Guest"
            let best = userBests[name] ?? 0
            if session.score > best {
                userBests[name] = session.score
            }
        }
        
        // Convert to ranked entries sorted by score descending
        let entries = userBests.map { LeaderboardEntry(username: $0.key, score: $0.value) }
        return entries.sorted { $0.score > $1.score }
    }
}
