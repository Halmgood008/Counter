import Foundation

protocol QuestionFactoryProtocol {
    func loadData(completion: @escaping (Result<Void, Error>) -> Void)
    func requestQuestion() -> QuizQuestion?
    func reset()
    var currentIndex: Int { get }
}

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoaderProtocol
    private var movies: [Movie] = []
    private(set) var currentIndex = 0
    
    init(moviesLoader: MoviesLoaderProtocol) {
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
        
        let randomThreshold = Double.random(in: 5.0...9.0)
        let roundedThreshold = (randomThreshold * 10).rounded() / 10
        let isGreater = Bool.random()
        
        let questionText: String
        let correctAnswer: Bool
        
        if isGreater {
            questionText = "Рейтинг этого фильма больше чем \(roundedThreshold)?"
            correctAnswer = movie.rating > roundedThreshold
        } else {
            questionText = "Рейтинг этого фильма меньше чем \(roundedThreshold)?"
            correctAnswer = movie.rating < roundedThreshold
        }
        
        let question = QuizQuestion(
            image: movie.imageURL,
            text: questionText,
            correctAnswer: correctAnswer
        )
        
        currentIndex += 1
        return question
    }
    
    func reset() {
        currentIndex = 0
        movies.shuffle()
    }
}
