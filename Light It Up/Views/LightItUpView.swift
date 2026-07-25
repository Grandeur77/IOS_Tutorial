import SwiftUI

// Local Sub-Mode Helper Model
enum LightItUpSubMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case colorTrap = "Color Trap"
    case memoryFlash = "Memory Flash"
    case doubleTrouble = "Double Trouble"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .classic: return "lightbulb.fill"
        case .colorTrap: return "exclamationmark.triangle.fill"
        case .memoryFlash: return "brain.headprofile.arrow.forward.to.brain"
        case .doubleTrouble: return "square.grid.2x2.fill"
        }
    }
    
    var description: String {
        switch self {
        case .classic: return "Tap the lit cards before time runs out."
        case .colorTrap: return "Tap blue safe cards. Avoid orange trap cards!"
        case .memoryFlash: return "Repeat the flashed sequence from memory."
        case .doubleTrouble: return "Tap all simultaneous lit cards to advance."
        }
    }
}

// Card Status representing layout visuals
enum CardStatus {
    case idle
    case litSafe
    case litTrap
    case litMemory
    case missed
}

struct LightItUpView: View {
    @State private var selectedMode: LightItUpSubMode? = nil
    @State private var localSelection: LightItUpSubMode? = nil
    
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
                LightItUpGameContainer(mode: mode) {
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
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.accentColor)
                        .shadow(color: .accentColor.opacity(0.4), radius: 8)
                    
                    Text("LIGHT IT UP")
                        .font(.system(size: 30, weight: .black, design: .monospaced))
                        .foregroundColor(headerTextColor)
                        .tracking(5)
                        .shadow(color: headerTextColor.opacity(colorScheme == .light ? 0.2 : 0.4), radius: 8)
                    
                    Text("Select a challenge mode to start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Selection Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(LightItUpSubMode.allCases) { sub in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                localSelection = sub
                            }
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: sub.icon)
                                    .font(.title2)
                                    .foregroundColor(localSelection == sub ? .yellow : (colorScheme == .light ? Color.black.opacity(0.4) : .white.opacity(0.6)))
                                
                                Text(sub.rawValue)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(sub.description)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(height: 30)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(localSelection == sub ? Color.accentColor : cardBorderColor, lineWidth: 1.5)
                            )
                            .shadow(color: localSelection == sub ? Color.accentColor.opacity(0.15) : .clear, radius: 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Start Button - always visible, matching Tap Frenzy dark yellow styling
                VStack(spacing: 16) {
                    Button(action: {
                        if let selection = localSelection {
                            withAnimation {
                                selectedMode = selection
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
                }
                .padding(.bottom, 75) // Lifted up to clear tab bar footer
            }
        }
    }
}

struct LightItUpGameContainer: View {
    let mode: LightItUpSubMode
    let onExit: () -> Void
    
    @State private var gameTimeRemaining: Double = 60.0
    @State private var litCardIndices: Set<Int> = []
    @State private var trapCardIndices: Set<Int> = []
    
    // Memory Flash States
    @State private var memorySequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var isFlashing: Bool = false
    @State private var flashActiveIndex: Int? = nil
    
    @State private var litTimeRemaining: Double = 1.5
    @State private var timer: Timer? = nil
    @State private var isGameOver: Bool = false
    @State private var score: Int = 0
    @State private var currentLevel: GameLevel = .l1
    @State private var showMissed: Bool = false
    @AppStorage("LightItUpHighScore") private var highScore: Int = 0
    @State private var newHighScore: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var countdownColor: Color {
        colorScheme == .light ? .orange : .yellow
    }
    
    private var mappedGameMode: GameMode {
        switch mode {
        case .classic: return .lightItUpClassic
        case .colorTrap: return .lightItUpColorTrap
        case .memoryFlash: return .lightItUpMemory
        case .doubleTrouble: return .lightItUpDouble
        }
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
                        restartGame()
                    },
                    onExit: {
                        onExit()
                    }
                )
            } else {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: onExit) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Text(mode.rawValue.uppercased())
                            .font(.headline.monospaced())
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Spacer().frame(width: 24)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Text("Light It Up")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Level: \(currentLevel.name)")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            Text(String(format: "Round Time: %.1fs", gameTimeRemaining))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("Score: \(score)")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)

                    ZStack {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columns), spacing: 12) {
                            ForEach(0..<currentLevel.totalCards, id: \.self) { idx in
                                CardView(status: cardStatus(for: idx))
                                    .onTapGesture {
                                        cardTapped(idx: idx)
                                    }
                                    .animation(.easeInOut, value: litCardIndices)
                            }
                        }
                        .padding()
                        .disabled(isFlashing) // prevent tapping during flash sequence
                    }
                    
                    VStack(spacing: 8) {
                        Text(isFlashing ? "MEMORIZE THE PATTERN!" : String(format: "Lit Time Left: %.1fs", max(0, litTimeRemaining)))
                            .font(.caption.monospacedDigit().bold())
                            .foregroundColor(isFlashing ? .yellow : countdownColor)
                        
                        ProgressView(value: max(0, litTimeRemaining), total: max(1.0, currentLevel.litWindow))
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 12)
                            .padding([.horizontal])
                            .tint(isFlashing ? Color.yellow : Color.accentColor)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func cardStatus(for idx: Int) -> CardStatus {
        if showMissed && (litCardIndices.contains(idx) || (mode == .colorTrap && trapCardIndices.contains(idx))) {
            return .missed
        }
        
        if isFlashing {
            return flashActiveIndex == idx ? .litMemory : .idle
        }
        
        if mode == .colorTrap {
            if litCardIndices.contains(idx) {
                return .litSafe
            } else if trapCardIndices.contains(idx) {
                return .litTrap
            }
        } else if mode == .memoryFlash {
            if playerSequence.contains(idx) {
                return .litMemory
            }
        } else {
            if litCardIndices.contains(idx) {
                return .litSafe
            }
        }
        
        return .idle
    }

    func startTimer() {
        timer?.invalidate()
        gameTimeRemaining = 60.0
        currentLevel = .l1
        litTimeRemaining = currentLevel.litWindow
        isGameOver = false
        newHighScore = false
        score = 0
        isFlashing = false
        flashActiveIndex = nil
        memorySequence = []
        playerSequence = []
        trapCardIndices = []
        
        setupRound()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if isFlashing { return }
            
            gameTimeRemaining -= 0.05
            litTimeRemaining -= 0.05

            if gameTimeRemaining <= 0 {
                gameTimeRemaining = 0
                SoundManager.shared.playFailure()
                endGame()
                return
            }

            let elapsed = 60.0 - gameTimeRemaining
            let newLvl = GameLevel.level(for: elapsed)
            if newLvl != currentLevel {
                currentLevel = newLvl
                if mode != .memoryFlash {
                    setupRound()
                }
            }

            if litTimeRemaining <= 0 {
                timer?.invalidate()
                showMissed = true
                SoundManager.shared.playFailure()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showMissed = false
                    endGame()
                }
            }
        }
    }
    
    func setupRound() {
        switch mode {
        case .classic:
            litCardIndices = selectNewLitCards(count: currentLevel.numLitCards, total: currentLevel.totalCards)
            litTimeRemaining = currentLevel.litWindow
        case .colorTrap:
            repositionColorTrapCards()
            litTimeRemaining = currentLevel.litWindow
        case .memoryFlash:
            startMemoryRound()
        case .doubleTrouble:
            setupDoubleTroubleCards()
            litTimeRemaining = currentLevel.litWindow
        }
    }

    func cardTapped(idx: Int) {
        guard !isGameOver, !isFlashing else { return }
        
        switch mode {
        case .classic:
            if litCardIndices.contains(idx) {
                score += 1
                litCardIndices.remove(idx)
                let available = Array(0..<currentLevel.totalCards).filter { !litCardIndices.contains($0) }
                if let newCard = available.randomElement() {
                    litCardIndices.insert(newCard)
                }
                litTimeRemaining = currentLevel.litWindow
                SoundManager.shared.playSuccess()
            } else {
                SoundManager.shared.playFailure()
                endGame()
            }
            
        case .colorTrap:
            if litCardIndices.contains(idx) {
                score += 1
                repositionColorTrapCards()
                litTimeRemaining = currentLevel.litWindow
                SoundManager.shared.playSuccess()
            } else if trapCardIndices.contains(idx) {
                SoundManager.shared.playFailure()
                showMissed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showMissed = false
                    endGame()
                }
            } else {
                SoundManager.shared.playFailure()
                endGame()
            }
            
        case .memoryFlash:
            let expectedIndex = playerSequence.count
            if expectedIndex < memorySequence.count && memorySequence[expectedIndex] == idx {
                playerSequence.append(idx)
                SoundManager.shared.playSuccess()
                if playerSequence.count == memorySequence.count {
                    score += memorySequence.count
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        startMemoryRound()
                    }
                }
            } else {
                SoundManager.shared.playFailure()
                endGame()
            }
            
        case .doubleTrouble:
            if litCardIndices.contains(idx) {
                score += 1
                litCardIndices.remove(idx)
                SoundManager.shared.playSuccess()
                if litCardIndices.isEmpty {
                    setupDoubleTroubleCards()
                    litTimeRemaining = currentLevel.litWindow
                }
            } else {
                SoundManager.shared.playFailure()
                endGame()
            }
        }
    }
    
    func repositionColorTrapCards() {
        let total = currentLevel.totalCards
        let safeCard = Int.random(in: 0..<total)
        litCardIndices = [safeCard]
        
        var available = Array(0..<total).filter { $0 != safeCard }
        if let trapCard = available.randomElement() {
            trapCardIndices = [trapCard]
        }
    }
    
    func setupDoubleTroubleCards() {
        let count = currentLevel.totalCards >= 6 ? 3 : 2
        var indices = Set<Int>()
        while indices.count < count {
            indices.insert(Int.random(in: 0..<currentLevel.totalCards))
        }
        litCardIndices = indices
    }
    
    func startMemoryRound() {
        isFlashing = true
        flashActiveIndex = nil
        playerSequence = []
        
        // Sequence length starts at 3 and scales with level
        let length = currentLevel.rawValue + 2
        var sequence: [Int] = []
        for _ in 0..<length {
            sequence.append(Int.random(in: 0..<currentLevel.totalCards))
        }
        memorySequence = sequence
        
        flashNextStep(index: 0)
    }
    
    func flashNextStep(index: Int) {
        guard index < memorySequence.count else {
            isFlashing = false
            flashActiveIndex = nil
            litTimeRemaining = Double(memorySequence.count) * 1.5
            return
        }
        
        flashActiveIndex = memorySequence[index]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            flashActiveIndex = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                flashNextStep(index: index + 1)
            }
        }
    }

    func selectNewLitCards(count: Int, total: Int) -> Set<Int> {
        var newIndices = Set<Int>()
        let safeCount = min(count, total)
        while newIndices.count < safeCount {
            newIndices.insert(Int.random(in: 0..<total))
        }
        return newIndices
    }

    func endGame() {
        timer?.invalidate()
        GameSessionStore.saveSession(mode: mappedGameMode, score: score)
        
        if score > highScore {
            highScore = score
            newHighScore = true
        }
        isGameOver = true
    }

    func restartGame() {
        startTimer()
    }
}

struct CardView: View {
    let status: CardStatus
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)
            .frame(minWidth: 60, minHeight: 80)
            .shadow(color: shadowColor, radius: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(colorScheme == .light ? Color.black.opacity(0.08) : Color.white.opacity(0.15), lineWidth: 1)
            )
    }
    
    private var backgroundColor: Color {
        switch status {
        case .idle:
            return colorScheme == .light ? Color.black.opacity(0.08) : Color.white.opacity(0.15)
        case .litSafe:
            return Color.blue
        case .litTrap:
            return Color.orange
        case .litMemory:
            return Color.yellow
        case .missed:
            return Color.red
        }
    }
    
    private var shadowColor: Color {
        switch status {
        case .idle:
            return .clear
        case .litSafe:
            return Color.blue.opacity(0.5)
        case .litTrap:
            return Color.orange.opacity(0.5)
        case .litMemory:
            return Color.yellow.opacity(0.5)
        case .missed:
            return Color.red.opacity(0.5)
        }
    }
}
