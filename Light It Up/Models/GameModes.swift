import Foundation

enum GameMode: String, Codable, CaseIterable {
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    // Tap Frenzy has multiple sub-modes
    case tapFrenzyDefault = "Tap Frenzy (Default)"
    case tapFrenzyCombo = "Tap Frenzy (Combo)"
    case tapFrenzyTrap = "Tap Frenzy (Trap)"
    case tapFrenzyMoving = "Tap Frenzy (Moving)"
    case tapFrenzyShrinking = "Tap Frenzy (Shrinking)"
    case tapFrenzyBurst = "Tap Frenzy (Burst)"
}
