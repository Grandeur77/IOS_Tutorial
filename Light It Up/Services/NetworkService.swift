import Foundation

class NetworkService {
    // An optional category ID filter
    func fetchQuestions(categoryID: Int? = nil) async throws -> [Question] {
        var urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        // User selected category 
        if let categoryID = categoryID {
            urlString += "&category=\(categoryID)"
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuizResponse.self, from: data)
        return response.results
    }
}
