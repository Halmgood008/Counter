import Foundation

enum NetworkError: Error {
    case urlError
    case noData
    case decodeError
    case serverError(statusCode: Int)
}

final class MoviesLoader {
    private let apiKey = "juv0ohccyeycmvbwn4du"
    
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "https://tv-api.com/api/top-250-movies?apikey=\(apiKey)") else {
            handler(.failure(NetworkError.urlError))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(TopMoviesResponse.self, from: data)
                DispatchQueue.main.async {
                    handler(.success(response.items))
                }
            } catch {
                print("Ошибка парсинга: \(error)")
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.decodeError))
                }
            }
        }.resume()
    }
}
