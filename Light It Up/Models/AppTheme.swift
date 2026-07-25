import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}
