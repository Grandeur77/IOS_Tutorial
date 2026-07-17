import SwiftUI

// MARK: - Confetti Particle Struct
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var xOffset: CGFloat
    var yOffset: CGFloat
    var rotation: Double
}

// MARK: - Custom Confetti View (No External Packages Needed)
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.xOffset, y: particle.yOffset)
                }
            }
            .onAppear {
                generateParticles(width: geo.size.width, height: geo.size.height)
                triggerAnimation(height: geo.size.height)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false) // Let player tap buttons underneath the confetti
    }
    
    private func generateParticles(width: CGFloat, height: CGFloat) {
        var temp: [ConfettiParticle] = []
        for _ in 0..<100 { // 100 pieces of confetti
            let size = CGFloat.random(in: 6...14)
            let particle = ConfettiParticle(
                color: colors.randomElement() ?? .red,
                size: size,
                xOffset: CGFloat.random(in: 0...width),
                yOffset: CGFloat.random(in: -height...0), // Start offscreen at top
                rotation: Double.random(in: 0...360)
            )
            temp.append(particle)
        }
        particles = temp
    }
    
    private func triggerAnimation(height: CGFloat) {
        withAnimation(.easeOut(duration: 4.0)) {
            for i in 0..<particles.count {
                particles[i].yOffset += height + 100 // Fall to bottom
                particles[i].xOffset += CGFloat.random(in: -80...80) // Drifting sway
                particles[i].rotation += Double.random(in: 360...1080) // Spinning fall
            }
        }
    }
}

// MARK: - Quiz Rush View
struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                    Text("Fetching Trivia Questions...")
                        .foregroundColor(.white.opacity(0.8))
                }
            case .loaded:
                if viewModel.isQuizFinished {
                    resultsView
                } else {
                    gameplayView
                }
            case .failed(let errorMessage):
                errorView(errorMessage)
            }
        }
        .task {
            await viewModel.loadQuestions()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    private var gameplayView: some View {
        let currentDisplayQuestion = viewModel.questions[viewModel.currentIndex]
        let currentQuestion = currentDisplayQuestion.question
        
        return VStack(spacing: 16) {
            // Header stats
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.subheadline.bold())
                    .foregroundColor(.accentColor)
                Spacer()
                if viewModel.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Streak: \(viewModel.streak)")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding([.horizontal, .top])
            
            HStack {
                Text("Score: \(viewModel.score)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            
            // Circular Countdown Timer
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 5)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.questionTimeRemaining / 10.0))
                    .stroke(
                        viewModel.questionTimeRemaining > 3.0 ? Color.accentColor : Color.red,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)
                    .animation(.linear(duration: 0.1), value: viewModel.questionTimeRemaining)
                
                Text(String(format: "%.0f", ceil(viewModel.questionTimeRemaining)))
                    .font(.body.bold())
                    .foregroundColor(.white)
            }
            
            // Question panel
            Text(currentQuestion.question.htmlDecoded)
                .font(.title3.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.15)))
                .padding(.horizontal)
            
            // Answer options
            VStack(spacing: 10) {
                ForEach(currentDisplayQuestion.shuffledAnswers, id: \.self) { answer in
                    Button(action: {
                        if viewModel.selectedAnswer == nil {
                            viewModel.answerQuestion(answer)
                            if answer != currentQuestion.correctAnswer {
                                triggerShake()
                            }
                        }
                    }) {
                        Text(answer.htmlDecoded)
                            .font(.body.bold())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(buttonColor(for: answer))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedAnswer != nil)
                    .offset(x: viewModel.selectedAnswer == answer && viewModel.answeredCorrectly == false ? shakeOffset : 0)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button("Back to Hub") {
                dismiss()
            }
            .foregroundColor(.accentColor)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Celebratory Results Screen
    private var resultsView: some View {
        ResultView(
            gameModeName: "Quiz Rush",
            score: viewModel.score,
            highScore: viewModel.highScore,
            newHighScore: viewModel.score > viewModel.highScore && viewModel.score > 0,
            onRestart: {
                Task {
                    await viewModel.loadQuestions()
                }
            },
            onExit: {
                dismiss()
            }
        )
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Network Failure")
                .font(.title.bold())
                .foregroundColor(.white)
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel.loadQuestions()
                }
            }
            .font(.body.bold())
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
    }
    
    private func triggerShake() {
        withAnimation(.default.repeatCount(3, autoreverses: true).speed(4)) {
            shakeOffset = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeOffset = 0
        }
    }
    
    private func buttonColor(for answer: String) -> Color {
        if let selected = viewModel.selectedAnswer {
            if answer == viewModel.questions[viewModel.currentIndex].question.correctAnswer {
                return .green
            }
            if answer == selected {
                return .red
            }
            return Color.gray.opacity(0.3)
        }
        return Color.accentColor
    }
}
