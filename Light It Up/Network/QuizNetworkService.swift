import Foundation

class QuizNetworkService {
    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
    
    func fetchQuestions() async throws -> [Question] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuizResponse.self, from: data)
        return response.results
    }
}
