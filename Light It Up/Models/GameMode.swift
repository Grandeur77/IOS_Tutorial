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
    
    // Light It Up sub-modes
    case lightItUpClassic = "Light It Up (Classic)"
    case lightItUpColorTrap = "Light It Up (Color Trap)"
    case lightItUpMemory = "Light It Up (Memory)"
    case lightItUpDouble = "Light It Up (Double)"
}
