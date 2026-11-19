import Foundation

protocol QuestionFactoryProtocol {
    func loadData(completion: @escaping (Result<Void, Error>) -> Void)
    func requestQuestion() -> QuizQuestion?
    func reset()
    var currentIndex: Int { get }
}

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoader
    private var movies: [Movie] = []
    private(set) var currentIndex = 0
    
    init(moviesLoader: MoviesLoader) {
        self.moviesLoader = moviesLoader
    }
    
    func loadData(completion: @escaping (Result<Void, Error>) -> Void) {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies.shuffled()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func requestQuestion() -> QuizQuestion? {
        guard currentIndex < 10, currentIndex < movies.count else { return nil }
        
        let movie = movies[currentIndex]
        let ratingThreshold = 6.0
        let question = QuizQuestion(
            image: movie.imageURL,
            text: "Рейтинг этого фильма больше чем \(Int(ratingThreshold))?",
            correctAnswer: movie.rating > ratingThreshold
        )
        
        currentIndex += 1
        return question
    }
    
    func reset() {
        currentIndex = 0
        movies.shuffle()
    }
}
