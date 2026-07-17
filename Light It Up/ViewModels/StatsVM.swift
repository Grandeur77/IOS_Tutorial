import SwiftUI
import Combine

class StatsVM: ObservableObject {
    // array for reload changes automatically
    @Published var sessions: [GameSession] = []
    
    // reloads the sessions from GameSessionStore
    func refresh() {
        self.sessions = GameSessionStore.loadSessions()
    }
    
    // total played game count calculation
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
    
    // returns the 5 most recently played games
    var recentSessions: [GameSession] {
        Array(sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5))
    }
}
