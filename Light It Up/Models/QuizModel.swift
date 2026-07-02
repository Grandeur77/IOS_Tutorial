import Foundation

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable, Equatable {
    var id: String { question }
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
            case category, type, difficulty, question
            case correctAnswer = "correct_answer"
            case incorrectAnswers = "incorrect_answers"
        }
}

struct DisplayableQuestion: Identifiable, Equatable {
    var id: String { question.question }
    let question: Question
    let shuffledAnswers: [String]
}

