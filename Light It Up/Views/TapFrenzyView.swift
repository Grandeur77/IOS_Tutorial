import SwiftUI

struct TapFrenzyView: View {
    @State private var selectedMode: TapFrenzyMode? = nil

    var body: some View {
        Group {
            if let mode = selectedMode {
                TapFrenzyGameView(mode: mode) {
                    selectedMode = nil
                }
            } else {
                modePicker
            }
        }
    }

    var modePicker: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 28) {
                Text("Tap Frenzy")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Choose Game Mode")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                ForEach(TapFrenzyMode.allCases) { mode in
                    Button(mode.rawValue) {
                        selectedMode = mode
                    }
                    .font(.title3.bold())
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                }
            }
        }
    }
}

struct TapFrenzyGameView: View {
    @Environment(\.dismiss) var dismiss // returning to the Hub
    
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
    let minButtonSize: CGFloat = 60
    let maxButtonSize: CGFloat = 170
    @State private var burstActive: Bool = false
    @State private var burstUsed: Bool = false
    @State private var burstTimer: Timer? = nil
    
    init(mode: TapFrenzyMode, onExit: @escaping () -> Void) {
        self.mode = mode
        self.onExit = onExit
        let storedHighScore = UserDefaults.standard.integer(forKey: "TapFrenzyHighScore_\(mode.rawValue)")
        self._highScore = State(initialValue: storedHighScore)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // If game over, show the shared ResultView
            if isGameOver {
                ResultView(
                    gameModeName: "Tap Frenzy (\(mode.rawValue))",
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
                // Normal Gameplay View
                VStack(spacing: 40) {
                    HStack(spacing: 10) {
                        Text("Score: \(score)")
                            .font(.title)
                            .foregroundColor(.white)
                        if mode == .combo, multiplier > 1 {
                            Text("×\(multiplier)")
                                .font(.title2.bold())
                                .foregroundColor(.accentColor)
                                .transition(.scale)
                                .animation(.spring(), value: multiplier)
                        }
                        Spacer()
                        Text(String(format: "%.1f", timeLeft))
                            .font(.title2.monospacedDigit())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Capsule().fill(Color.accentColor.opacity(0.2)))
                    }
                    .padding([.top, .horizontal])
                    Spacer()
                    GeometryReader { geo in
                        ZStack {
                            if mode == .moving {
                                Button(action: { tapAction() }) {
                                    Text("TAP")
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .frame(width: maxButtonSize, height: maxButtonSize)
                                        .background(Color.accentColor)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .shadow(radius: isGameOver ? 0 : 16)
                                }
                                .disabled(isGameOver)
                                .position(x: geo.size.width * buttonPosition.x,
                                          y: geo.size.height * buttonPosition.y)
                            } else {
                                Button(action: { tapAction() }) {
                                    Text("TAP")
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(currentButtonColor)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .shadow(radius: isGameOver ? 0 : 16)
                                        .overlay(
                                            Group {
                                                if burstActive && mode == .burst {
                                                    Circle().stroke(Color.yellow, lineWidth: 7).scaleEffect(1.1)
                                                        .opacity(0.7)
                                                }
                                            }
                                        )
                                }
                                .disabled(isGameOver)
                                .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                    .frame(height: 350)
                    Spacer()
                    ProgressView(value: timeLeft, total: 10)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 12)
                        .padding([.horizontal])
                        .tint(Color.accentColor)
                    Button("Back") {
                        stopAllTimers()
                        onExit()
                    }
                    .padding()
                    .foregroundColor(.accentColor)
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopAllTimers() }
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
        case .trapColour:
            if isTrapGreen {
                score += 5
            } else if buttonColor == .gray {
                score = max(0, score - 2)
            } else {
                score += 1
            }
        case .moving:
            score += 1
        case .shrinking:
            score += 1
        case .burst:
            if burstActive {
                score += 2
            } else {
                score += 1
            }
        default:
            score += 1
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
        isGameOver = true
        multiplier = 1
        lastTapTime = nil
        stopAllTimers()
        
        let oldHighScore = highScore
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "TapFrenzyHighScore_\(mode.rawValue)")
            highScore = score
            newHighScore = true
        }
        
        // Map submode to GameMode
        let mappedMode: GameMode
        switch mode {
        case .combo: mappedMode = .tapFrenzyCombo
        case .trapColour: mappedMode = .tapFrenzyTrap
        case .moving: mappedMode = .tapFrenzyMoving
        case .shrinking: mappedMode = .tapFrenzyShrinking
        case .burst: mappedMode = .tapFrenzyBurst
        default: mappedMode = .tapFrenzyDefault
        }
        
        // Save Session
        GameSessionStore.saveSession(mode: mappedMode, score: score)
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
