import Foundation
import CoreLocation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double?
    let longitude: Double?
    let username: String?
}

class GameSessionStore {
    private static let userDefaultsKey = "SavedGameSessions"
    
    // Add a new game session
    static func saveSession(mode: GameMode, score: Int) {
        var sessions = loadSessions()
        
        // Fetch current coordinates from LocationService singleton
        let currentLocation = LocationService.shared.lastLocation
        
        var lat: Double? = currentLocation?.coordinate.latitude
        var lon: Double? = currentLocation?.coordinate.longitude
        
        // If GPS is unavailable (e.g. Simulator without simulated route), use mock coordinates for testing
        if lat == nil || lon == nil {
            let baseLat = 37.7749 // San Francisco
            let baseLon = -122.4194
            lat = baseLat + Double.random(in: -0.05...0.05)
            lon = baseLon + Double.random(in: -0.05...0.05)
        }
        
        // Fetch the active player's name from AppStorage
        let activeUsername = UserDefaults.standard.string(forKey: "PlayerDisplayName") ?? "Guest"
        
        let newSession = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: lat,
            longitude: lon,
            username: activeUsername 
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
