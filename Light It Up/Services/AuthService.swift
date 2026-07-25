import Foundation

class AuthService {
    static let shared = AuthService()
    
    private let databaseKey = "ArcadeRegisteredUsers"
    
    private init() {}
    
    // Loads the registered users dictionary from UserDefaults database
    private func loadUsers() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: databaseKey) else { return [:] }
        let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        return decoded ?? [:]
    }
    
    // Saves the updated registered users dictionary to UserDefaults database
    private func saveUsers(_ users: [String: String]) {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: databaseKey)
        }
    }
    
    // Registers a new user
    func register(username: String, password: String) -> Bool {
        let trimmedUsername = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername.isEmpty && !trimmedPassword.isEmpty else { return false }
        
        var users = loadUsers()
        
        // If the user already exists in the database, block registration
        if users[trimmedUsername] != nil {
            return false
        }
        
        // Add credentials to the database
        users[trimmedUsername] = trimmedPassword
        saveUsers(users)
        return true
    }
    
    // Log in a user
    func login(username: String, password: String) -> Bool {
        let trimmedUsername = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername.isEmpty && !trimmedPassword.isEmpty else { return false }
        
        let users = loadUsers()
        
        // Check if credentials match exactly
        if let storedPassword = users[trimmedUsername], storedPassword == trimmedPassword {
            return true
        }
        
        return false
    }
    
    // Updates the user name
    func updateUsername(from oldName: String, to newName: String) -> Bool {
        let oldLower = oldName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let newLower = newName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !oldLower.isEmpty && !newLower.isEmpty else { return false }
        guard oldLower != newLower else { return true } // No change needed
        
        var users = loadUsers()
        
        // Block change if the target username is already registered to someone else
        if users[newLower] != nil {
            return false
        }
        
        // Rename key in dictionary
        if let password = users[oldLower] {
            users[newLower] = password
            users.removeValue(forKey: oldLower)
            saveUsers(users)
            return true
        }
        
        return false
    }
}
