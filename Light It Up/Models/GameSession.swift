import Foundation
import CoreLocation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double?
    let longitude: Double?
}

class GameSessionStore {
    private static let userDefaultsKey = "SavedGameSessions"
    
    // Add a new game session
    static func saveSession(mode: GameMode, score: Int) {
        var sessions = loadSessions()
        
        // Fetch current coordinates from LocationService singleton
        let currentLocation = LocationService.shared.lastLocation
        
        let newSession = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: currentLocation?.coordinate.latitude,
            longitude: currentLocation?.coordinate.longitude
        )
        
        sessions.append(newSession)
        
        // Encode and save
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // Loads all saved game sessions
    static func loadSessions() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return [] }
        let decoded = try? JSONDecoder().decode([GameSession].self, from: data)
        return decoded ?? []
    }
    
    // clear history
    static func clearAllSessions() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
