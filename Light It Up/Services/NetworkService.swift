import Foundation

class NetworkService {
    // Fetch trivia questions filterable by category and difficulty
    func fetchQuestions(categoryID: Int? = nil, difficulty: String? = nil) async throws -> [Question] {
        var urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        if let categoryID = categoryID {
            urlString += "&category=\(categoryID)"
        }
        
        if let difficulty = difficulty {
            urlString += "&difficulty=\(difficulty)"
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuizResponse.self, from: data)
        return response.results
    }
}
