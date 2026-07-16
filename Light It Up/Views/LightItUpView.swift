import SwiftUI

struct LightItUpView: View {
    @State private var gameTimeRemaining: Double = 60.0
    @State private var litCardIndices: Set<Int> = []
    @State private var litTimeRemaining: Double = 1.5
    @State private var timer: Timer? = nil
    @State private var isGameOver: Bool = false
    @State private var score: Int = 0
    @State private var currentLevel: GameLevel = .l1
    @State private var showMissed: Bool = false
    @AppStorage("LightItUpHighScore") private var highScore: Int = 0
    @State private var newHighScore: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Light It Up")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level: \(currentLevel.name)")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        Text(String(format: "Round Time: %.1fs", gameTimeRemaining))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("Score: \(score)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                ZStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columns), spacing: 12) {
                        ForEach(0..<currentLevel.totalCards, id: \.self) { idx in
                            CardView(isLit: litCardIndices.contains(idx), showMissed: showMissed && litCardIndices.contains(idx))
                                .onTapGesture {
                                    cardTapped(idx: idx)
                                }
                                .animation(.easeInOut, value: litCardIndices)
                        }
                    }
                    .padding()
                    .disabled(isGameOver)

                    if isGameOver {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                        VStack(spacing: 18) {
                            Text("Game Over!")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                            Text("Final Score: \(score)")
                                .font(.title2)
                                .foregroundColor(.white)
                            if newHighScore {
                                Text("New High Score!")
                                    .font(.headline.bold())
                                    .foregroundColor(.accentColor)
                            } else {
                                Text("High Score: \(highScore)")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Button("Restart") {
                                restartGame()
                            }
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 6)
                        }
                        .padding()
                    }
                }
                
                VStack(spacing: 8) {
                    Text(String(format: "Lit Time Left: %.1fs", max(0, litTimeRemaining)))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.yellow)
                        .opacity(isGameOver ? 0 : 1)
                    
                    ProgressView(value: max(0, litTimeRemaining), total: currentLevel.litWindow)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 12)
                        .padding([.horizontal])
                        .opacity(isGameOver ? 0 : 1)
                        .tint(Color.accentColor)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer?.invalidate()
        gameTimeRemaining = 60.0
        currentLevel = .l1
        litTimeRemaining = currentLevel.litWindow
        litCardIndices = selectNewLitCards(count: currentLevel.numLitCards, total: currentLevel.totalCards)
        showMissed = false
        isGameOver = false
        newHighScore = false
        score = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            gameTimeRemaining -= 0.05
            litTimeRemaining -= 0.05

            if gameTimeRemaining <= 0 {
                gameTimeRemaining = 0
                endGame()
                return
            }

            let elapsed = 60.0 - gameTimeRemaining
            let newLvl = GameLevel.level(for: elapsed)
            if newLvl != currentLevel {
                currentLevel = newLvl
                litCardIndices = selectNewLitCards(count: currentLevel.numLitCards, total: currentLevel.totalCards)
                litTimeRemaining = currentLevel.litWindow
                showMissed = false
            }

            if litTimeRemaining <= 0 {
                timer?.invalidate()
                showMissed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showMissed = false
                    endGame()
                }
            }
        }
    }

    func cardTapped(idx: Int) {
        guard !isGameOver else { return }
        if litCardIndices.contains(idx) {
            score += 1
            litCardIndices.remove(idx)

            var available = Array(0..<currentLevel.totalCards).filter { !litCardIndices.contains($0) }
            if let newCard = available.randomElement() {
                litCardIndices.insert(newCard)
            }

            litTimeRemaining = currentLevel.litWindow
        } else {
            endGame()
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
        isGameOver = true
        if score > highScore {
            highScore = score
            newHighScore = true
        }
        
        // Save the completed game session
        GameSessionStore.saveSession(mode: .lightItUp, score: score)
    }
    func restartGame() {
        startTimer()
    }
}

struct CardView: View {
    let isLit: Bool
    let showMissed: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(showMissed ? Color.red : (isLit ? Color.accentColor : Color.gray.opacity(0.5)))
            .frame(minWidth: 60, minHeight: 80)
            .shadow(color: isLit ? Color.accentColor.opacity(0.5) : .clear, radius: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
            )
    }
}
