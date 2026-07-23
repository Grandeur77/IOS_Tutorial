import SwiftUI

struct QuizGenre: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let color: Color
    
    static let allGenres: [QuizGenre] = [
        QuizGenre(id: 9, name: "General Knowledge", icon: "globe", color: .blue),
        QuizGenre(id: 18, name: "Technology", icon: "desktopcomputer", color: .purple),
        QuizGenre(id: 17, name: "Science", icon: "atom", color: .green),
        QuizGenre(id: 21, name: "Sports", icon: "sportscourt.fill", color: .orange),
        QuizGenre(id: 23, name: "History", icon: "scroll.fill", color: .yellow),
        QuizGenre(id: 22, name: "Geography", icon: "map.fill", color: .red)
    ]
}

// Quiz Rush View
struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) var dismiss
    
    // View States
    @State private var selectedGenre: QuizGenre? = nil
    @State private var isGameStarted = false
    @State private var shakeOffset: CGFloat = 0
    @State private var animateBlob = false
    
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
        ZStack {
            baseBackgroundColor.ignoresSafeArea()
            
            if colorScheme == .dark {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 90)
                        .offset(x: animateBlob ? -60 : 60, y: animateBlob ? -80 : 80)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.08))
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .offset(x: animateBlob ? 80 : -80, y: animateBlob ? 90 : -90)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                        animateBlob.toggle()
                    }
                }
                .ignoresSafeArea()
            }
            
            // Router logic
            if !isGameStarted {
                genreSelectionView
            } else {
                activeQuizView
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    // Genre Selection View
    private var genreSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 10)
            
            // Header
            VStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundColor(.accentColor)
                    .shadow(color: .accentColor.opacity(0.4), radius: 8)
                
                Text("CHOOSE TOPIC")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(headerTextColor)
                    .tracking(4)
                    .shadow(color: headerTextColor.opacity(colorScheme == .light ? 0.2 : 0.4), radius: 6)
                
                Text("Select a genre to test your skills")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Genres
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(QuizGenre.allGenres) { genre in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedGenre = genre
                        }
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: genre.icon)
                                .font(.title)
                                .foregroundColor(selectedGenre?.id == genre.id ? genre.color : (colorScheme == .light ? Color.black.opacity(0.4) : .white.opacity(0.6)))
                            
                            Text(genre.name)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(selectedGenre?.id == genre.id ? (colorScheme == .light ? Color.accentColor.opacity(0.1) : Color.white.opacity(0.06)) : cardBackgroundColor)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    selectedGenre?.id == genre.id ? genre.color : cardBorderColor,
                                    lineWidth: selectedGenre?.id == genre.id ? 2 : 1
                                )
                                .shadow(color: selectedGenre?.id == genre.id ? genre.color.opacity(0.3) : .clear, radius: 4)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action Start button
            VStack(spacing: 16) {
                Button(action: {
                    if let genre = selectedGenre {
                        withAnimation {
                            isGameStarted = true
                        }
                        Task {
                            await viewModel.loadQuestions(categoryID: genre.id)
                        }
                    }
                }) {
                    Text("PLAY")
                        .font(.system(.headline, design: .monospaced).bold())
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group { // <-- Wrapped in Group to compile-safely return different view types
                                if selectedGenre == nil {
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
                        .shadow(color: selectedGenre == nil ? .clear : .yellow.opacity(0.4), radius: 6)
                }
                .disabled(selectedGenre == nil)
                .padding(.horizontal, 24)
                
                Button("Exit Game Hub") {
                    dismiss()
                }
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
    
    // Active Quiz State Router
    private var activeQuizView: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                    Text("Loading Questions...")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.secondary)
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
    }
    
    // Gameplay View
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
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            
            // Circular Countdown Timer
            ZStack {
                Circle()
                    .stroke(colorScheme == .light ? Color.black.opacity(0.08) : Color.white.opacity(0.06), lineWidth: 5)
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
                    .foregroundColor(.primary)
            }
            
            // Glass Question panel
            Text(currentQuestion.question.htmlDecoded)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity)
                .background(cardBackgroundColor)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(cardBorderColor, lineWidth: 1)
                )
                .padding(.horizontal)
            
            // Answer options
            VStack(spacing: 12) {
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
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(buttonColor(for: answer))
                            .foregroundColor(viewModel.selectedAnswer == nil ? .primary : .white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(buttonBorderColor(for: answer), lineWidth: 1)
                            )
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
            .font(.subheadline.bold())
            .foregroundColor(.secondary)
            .padding(.bottom, 8)
        }
    }
    
    // Celebratory Results Screen
    private var resultsView: some View {
        ResultView(
            gameMode: .quizRush,
            score: viewModel.score,
            highScore: viewModel.highScore,
            newHighScore: viewModel.score > viewModel.highScore && viewModel.score > 0,
            onRestart: {
                // Play Again resets selection state to let players pick another topic
                withAnimation {
                    isGameStarted = false
                    selectedGenre = nil
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
                .foregroundColor(.primary)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
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
            return colorScheme == .light ? Color.black.opacity(0.01) : Color.white.opacity(0.01)
        }
        return colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.04)
    }
    
    private func buttonBorderColor(for answer: String) -> Color {
        if let selected = viewModel.selectedAnswer {
            if answer == viewModel.questions[viewModel.currentIndex].question.correctAnswer {
                return .green
            }
            if answer == selected {
                return .red
            }
            return colorScheme == .light ? Color.black.opacity(0.03) : Color.white.opacity(0.03)
        }
        return colorScheme == .light ? Color.black.opacity(0.08) : Color.white.opacity(0.08)
    }
}

#Preview {
    QuizRushView()
}
