import SwiftUI

// Local Sub-Mode Helper Model
struct TapFrenzySubMode: Identifiable {
    let mode: TapFrenzyMode
    let icon: String
    let description: String
    
    var id: String { mode.rawValue }
    
    static let allSubModes: [TapFrenzySubMode] = [
        TapFrenzySubMode(mode: .`default`, icon: "hand.tap.fill", description: "Standard clicking challenge."),
        TapFrenzySubMode(mode: .combo, icon: "multiply", description: "Tap rapidly to increase multipliers."),
        TapFrenzySubMode(mode: .trapColour, icon: "exclamationmark.triangle.fill", description: "Avoid tapping when color turns gray."),
        TapFrenzySubMode(mode: .moving, icon: "scope", description: "The button teleports around the screen."),
        TapFrenzySubMode(mode: .shrinking, icon: "arrow.down.right.and.arrow.up.left", description: "The button gets smaller over time."),
        TapFrenzySubMode(mode: .burst, icon: "sparkles", description: "Double points when yellow ring glows.")
    ]
}

struct TapFrenzyView: View {
    @State private var selectedMode: TapFrenzyMode? = nil
    @State private var localSelection: TapFrenzySubMode? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var cardBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.08)
    }
    
    private var headerTextColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }

    var body: some View {
        Group {
            if let mode = selectedMode {
                TapFrenzyGameView(mode: mode) {
                    selectedMode = nil
                    localSelection = nil
                }
            } else {
                modePicker
            }
        }
    }

    var modePicker: some View {
        ZStack {
            baseBackgroundColor.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 10)
              
                VStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.accentColor)
                        .shadow(color: .accentColor.opacity(0.4), radius: 8)
                    
                    Text("TAP FRENZY")
                        .font(.system(size: 30, weight: .black, design: .monospaced))
                        .foregroundColor(headerTextColor)
                        .tracking(5)
                        .shadow(color: headerTextColor.opacity(colorScheme == .light ? 0.2 : 0.4), radius: 8)
                    
                    Text("Select a sub-mode to challenge")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Selection Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(TapFrenzySubMode.allSubModes) { sub in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                localSelection = sub
                            }
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: sub.icon)
                                    .font(.title2)
                                    .foregroundColor(localSelection?.id == sub.id ? .yellow : (colorScheme == .light ? Color.black.opacity(0.4) : .white.opacity(0.6)))
                                
                                Text(sub.mode.rawValue)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(sub.description)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, minHeight: 110)
                            .background(localSelection?.id == sub.id ? (colorScheme == .light ? Color.yellow.opacity(0.12) : Color.white.opacity(0.06)) : cardBackgroundColor)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(
                                        localSelection?.id == sub.id ? Color.yellow : cardBorderColor,
                                        lineWidth: localSelection?.id == sub.id ? 2 : 1
                                    )
                                    .shadow(color: localSelection?.id == sub.id ? .yellow.opacity(0.3) : .clear, radius: 4)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Start Button
                VStack(spacing: 16) {
                    Button(action: {
                        if let sub = localSelection {
                            withAnimation {
                                selectedMode = sub.mode
                            }
                        }
                    }) {
                        Text("PLAY")
                            .font(.system(.headline, design: .monospaced).bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Group {
                                    if localSelection == nil {
                                        colorScheme == .light ? Color.black.opacity(0.1) : Color.gray.opacity(0.3)
                                    } else {
                                        LinearGradient(
                                            colors: [.yellow, Color.orange.opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                }
                            )
                            .cornerRadius(14)
                            .shadow(color: localSelection == nil ? .clear : .yellow.opacity(0.4), radius: 6)
                    }
                    .disabled(localSelection == nil)
                    .padding(.horizontal, 24)
                    
                    Button("Exit Game Hub") {
                        selectedMode = nil
                        localSelection = nil
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 75)
            }
        }
    }
}

// MARK: - Game View
struct TapFrenzyGameView: View {
    @Environment(\.dismiss) var dismiss
    
    let mode: TapFrenzyMode
    let onExit: () -> Void
    @State private var score: Int = 0
    @State private var highScore: Int = 0
    @State private var timeLeft: Double = 10
    @State private var isGameOver: Bool = false
    @State private var timer: Timer? = nil
    @State private var newHighScore: Bool = false
    @State private var multiplier: Int = 1
    @State private var lastTapTime: Date? = nil
    
    @State private var buttonColor: Color = .accentColor
    @State private var trapTimer: Timer? = nil
    @State private var isTrapGreen: Bool = false
    @State private var buttonPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var targetMoveTimer: Timer? = nil
    let minButtonSize: CGFloat = 80
    let maxButtonSize: CGFloat = 160
    @State private var burstActive: Bool = false
    @State private var burstUsed: Bool = false
    @State private var burstTimer: Timer? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var highlightColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
    private var mappedGameMode: GameMode {
        switch mode {
        case .combo: return .tapFrenzyCombo
        case .trapColour: return .tapFrenzyTrap
        case .moving: return .tapFrenzyMoving
        case .shrinking: return .tapFrenzyShrinking
        case .burst: return .tapFrenzyBurst
        default: return .tapFrenzyDefault
        }
    }
    
    init(mode: TapFrenzyMode, onExit: @escaping () -> Void) {
        self.mode = mode
        self.onExit = onExit
        let storedHighScore = UserDefaults.standard.integer(forKey: "TapFrenzyHighScore_\(mode.rawValue)")
        self._highScore = State(initialValue: storedHighScore)
    }
    
    var body: some View {
        ZStack {
            baseBackgroundColor.ignoresSafeArea()
            
            if isGameOver {
                ResultView(
                    gameMode: mappedGameMode,
                    score: score,
                    highScore: highScore,
                    newHighScore: newHighScore,
                    onRestart: {
                        restart()
                    },
                    onExit: {
                        dismiss()
                    }
                )
            } else {
                VStack(spacing: 36) {
                    // Header Stats
                    HStack(spacing: 12) {
                        Text("SCORE: \(score)")
                            .font(.system(.title2, design: .monospaced).bold())
                            .foregroundColor(.primary)
                        
                        if mode == .combo, multiplier > 1 {
                            Text("×\(multiplier)")
                                .font(.title.bold())
                                .foregroundColor(highlightColor)
                                .transition(.scale)
                                .animation(.spring(), value: multiplier)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", timeLeft))
                            .font(.system(.title3, design: .monospaced).bold())
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.04))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(colorScheme == .light ? Color.black.opacity(0.08) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .padding([.top, .horizontal])
                    
                    Spacer()
                    
                    // Tap Area Frame
                    GeometryReader { geo in
                        ZStack {
                            if mode == .moving {
                                Button(action: { tapAction() }) {
                                    arcadeButton(size: maxButtonSize)
                                }
                                .disabled(isGameOver)
                                .position(x: geo.size.width * buttonPosition.x,
                                          y: geo.size.height * buttonPosition.y)
                            } else {
                                Button(action: { tapAction() }) {
                                    arcadeButton(size: buttonSize)
                                }
                                .disabled(isGameOver)
                                .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                    .frame(height: 350)
                    
                    Spacer()
                    
                    // Time Left Progress
                    ProgressView(value: timeLeft, total: 10)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 8)
                        .padding(.horizontal, 24)
                        .tint(Color.accentColor)
                    
                    Button("Back to Selector") {
                        stopAllTimers()
                        onExit()
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopAllTimers() }
    }

    private func arcadeButton(size: CGFloat) -> some View {
        let displayColor = currentButtonColor
        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [displayColor, displayColor.opacity(0.85)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 4)
                )
                .shadow(color: displayColor.opacity(0.65), radius: 14)
                .frame(width: size, height: size)
            
            Text("TAP")
                .font(.system(size: size * 0.28, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
            
            if burstActive && mode == .burst {
                Circle()
                    .strokeBorder(Color.yellow, lineWidth: 6)
                    .scaleEffect(1.08)
                    .shadow(color: .yellow.opacity(0.6), radius: 6)
                    .frame(width: size, height: size)
            }
        }
    }
    
    var buttonSize: CGFloat {
        if mode == .shrinking {
            let frac = max(0, min(1, timeLeft / 10))
            return minButtonSize + frac * (maxButtonSize - minButtonSize)
        }
        return maxButtonSize
    }
    
    var currentButtonColor: Color {
        switch mode {
        case .trapColour: return buttonColor
        default: return .accentColor
        }
    }
    
    func tapAction() {
        guard !isGameOver else { return }
        switch mode {
        case .combo:
            let now = Date()
            if let last = lastTapTime {
                if now.timeIntervalSince(last) <= 0.5 {
                    multiplier += 1
                } else {
                    multiplier = 1
                }
            } else {
                multiplier = 1
            }
            lastTapTime = now
            score += multiplier
            SoundManager.shared.playSuccess()
        case .trapColour:
            if isTrapGreen {
                score += 5
                SoundManager.shared.playSuccess()
            } else if buttonColor == .gray {
                score = max(0, score - 2)
                SoundManager.shared.playFailure()
            } else {
                score += 1
                SoundManager.shared.playSuccess()
            }
        case .moving:
            score += 1
            SoundManager.shared.playSuccess()
        case .shrinking:
            score += 1
            SoundManager.shared.playSuccess()
        case .burst:
            if burstActive {
                score += 2
                SoundManager.shared.playSuccess()
            } else {
                score += 1
                SoundManager.shared.playSuccess()
            }
        default:
            score += 1
            SoundManager.shared.playSuccess()
        }
    }
    
    func startTimer() {
        stopAllTimers()
        score = 0
        timeLeft = 10
        isGameOver = false
        newHighScore = false
        multiplier = 1
        lastTapTime = nil
        isTrapGreen = false
        burstActive = false
        burstUsed = false
        buttonColor = .accentColor
        buttonPosition = CGPoint(x: 0.5, y: 0.5)
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            timeLeft -= 0.05
            if timeLeft <= 0 {
                timer?.invalidate()
                SoundManager.shared.playFailure()
                gameOver()
            }
        }
        if mode == .trapColour {
            trapTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                let rand = Int.random(in: 0...2)
                if rand == 0 {
                    buttonColor = .green
                    isTrapGreen = true
                } else if rand == 1 {
                    buttonColor = .gray
                    isTrapGreen = false
                } else {
                    buttonColor = .accentColor
                    isTrapGreen = false
                }
            }
        }
        if mode == .moving {
            targetMoveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                buttonPosition = CGPoint(x: Double.random(in: 0.2...0.8), y: Double.random(in: 0.2...0.8))
            }
        }
        if mode == .burst {
            let burstDelay = Double.random(in: 2...6)
            burstTimer = Timer.scheduledTimer(withTimeInterval: burstDelay, repeats: false) { _ in
                burstActive = true
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                    burstActive = false
                    burstUsed = true
                }
            }
        }
    }
    
    func gameOver() {
        multiplier = 1
        lastTapTime = nil
        stopAllTimers()
        
        let oldHighScore = highScore
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "TapFrenzyHighScore_\(mode.rawValue)")
            highScore = score
            newHighScore = true
        }
        
        let mappedMode: GameMode
        switch mode {
        case .combo: mappedMode = .tapFrenzyCombo
        case .trapColour: mappedMode = .tapFrenzyTrap
        case .moving: mappedMode = .tapFrenzyMoving
        case .shrinking: mappedMode = .tapFrenzyShrinking
        case .burst: mappedMode = .tapFrenzyBurst
        default: mappedMode = .tapFrenzyDefault
        }
        
        // Save the completed game session FIRST
        GameSessionStore.saveSession(mode: mappedMode, score: score)
        
        isGameOver = true
    }
    
    func restart() {
        startTimer()
    }
    
    func stopAllTimers() {
        timer?.invalidate(); timer = nil
        trapTimer?.invalidate(); trapTimer = nil
        targetMoveTimer?.invalidate(); targetMoveTimer = nil
        burstTimer?.invalidate(); burstTimer = nil
    }
}
