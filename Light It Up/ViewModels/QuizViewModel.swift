import SwiftUI
import Combine

enum QuizViewState {
    case loading
    case loaded
    case failed(String)
}

class QuizViewModel: ObservableObject {
    @Published var questions: [DisplayableQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var viewState: QuizViewState = .loading
    @Published var isQuizFinished: Bool = false
    @Published var selectedAnswer: String? = nil
    @Published var answeredCorrectly: Bool? = nil
    
    // Time Attack properties
    @Published var questionTimeRemaining: Double = 10.0
    private var timer: Timer? = nil
    
    var highScore: Int {
        UserDefaults.standard.integer(forKey: "QuizRushHighScore")
    }
    
    private let networkService = NetworkService()
    
    @MainActor
    func loadQuestions() async {
        stopQuestionTimer()
        viewState = .loading
        isQuizFinished = false
        currentIndex = 0
        score = 0
        streak = 0
        questions = []
        selectedAnswer = nil
        answeredCorrectly = nil
        
        do {
            let fetchedQuestions = try await networkService.fetchQuestions()
            
            let displayable = fetchedQuestions.map { question in
                DisplayableQuestion(
                    question: question,
                    shuffledAnswers: (question.incorrectAnswers + [question.correctAnswer]).shuffled()
                )
            }
            
            self.questions = displayable
            if displayable.isEmpty {
                self.viewState = .failed("No questions returned from API.")
            } else {
                self.viewState = .loaded
                startQuestionTimer() // Start timer for the first question
            }
        } catch {
            self.viewState = .failed(error.localizedDescription)
        }
    }
    
    @MainActor
    func answerQuestion(_ answer: String) {
        stopQuestionTimer() // Stop the timer immediately on answer selection
        guard currentIndex < questions.count else { return }
        let currentQuestion = questions[currentIndex].question
        
        selectedAnswer = answer
        let isCorrect = answer == currentQuestion.correctAnswer
        
        if isCorrect {
            answeredCorrectly = true
            streak += 1
            let streakBonus = (streak - 1) * 5
            score += 10 + streakBonus
        } else {
            answeredCorrectly = false
            streak = 0
            score = max(0, score - 3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.advanceQuestion()
        }
    }
    
    @MainActor
    private func handleTimeout() {
        stopQuestionTimer()
        guard currentIndex < questions.count else { return }
        
        // Timeout counts as incorrect answer
        answeredCorrectly = false
        selectedAnswer = "" // Empty indicates timeout
        streak = 0
        score = max(0, score - 3)
        
        // Let the user see the correct answer briefly before advancing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.advanceQuestion()
        }
    }
    
    @MainActor
    private func advanceQuestion() {
        self.answeredCorrectly = nil
        self.selectedAnswer = nil
        if self.currentIndex + 1 < self.questions.count {
            self.currentIndex += 1
            self.startQuestionTimer()
        } else {
            self.isQuizFinished = true
            if self.score > self.highScore {
                UserDefaults.standard.set(self.score, forKey: "QuizRushHighScore")
            }
            
            // Save the completed game session
            GameSessionStore.saveSession(mode: .quizRush, score: self.score)
        }
    }
    
    // Timer Control Methods
    private func startQuestionTimer() {
        stopQuestionTimer()
        questionTimeRemaining = 10.0
        
        // Run timer on main actor thread so it updates UI safely
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.questionTimeRemaining -= 0.1
                if self.questionTimeRemaining <= 0 {
                    self.questionTimeRemaining = 0
                    self.handleTimeout()
                }
            }
        }
    }
    
    func stopQuestionTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func cleanup() {
        stopQuestionTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
}
