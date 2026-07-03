import SwiftUI

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
        
        return VStack(spacing: 24) {
            // Header stats
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Spacer()
                if viewModel.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Streak: \(viewModel.streak)")
                            .font(.headline.bold())
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.horizontal)
            
            HStack {
                Text("Score: \(viewModel.score)")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Circular Countdown Timer
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.questionTimeRemaining / 10.0))
                    .stroke(
                        viewModel.questionTimeRemaining > 3.0 ? Color.accentColor : Color.red,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                    // Smooth linear transition for the shrinking circle outline
                    .animation(.linear(duration: 0.1), value: viewModel.questionTimeRemaining)
                
                Text(String(format: "%.0f", ceil(viewModel.questionTimeRemaining)))
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
            
            // Question panel
            Text(currentQuestion.question.htmlDecoded)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.15)))
                .padding(.horizontal)
            
            Spacer()
            
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
                            .padding()
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
            .padding(.bottom)
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 24) {
            Text("Quiz Finished!")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Text("Final Score")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("\(viewModel.score)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
            }
            .padding(40)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.15)))
            
            Button("Play Again") {
                Task {
                    await viewModel.loadQuestions()
                }
            }
            .font(.title3.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.horizontal)
            
            Button("Back to Hub") {
                dismiss()
            }
            .foregroundColor(.accentColor)
            .padding(.top)
        }
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
