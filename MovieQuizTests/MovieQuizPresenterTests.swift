import XCTest
@testable import MovieQuiz

class MovieQuizPresenterTests: XCTestCase {
    
    func testConvertModel() throws {
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader())
        let statisticService = StatisticService()
        let presenter = MovieQuizPresenter(questionFactory: questionFactory, statisticService: statisticService)
        
        let question = QuizQuestion(
            image: "https://example.com/image.jpg",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        )

        let viewModel = presenter.convert(model: question)

        XCTAssertEqual(viewModel.image, "https://example.com/image.jpg")
        XCTAssertEqual(viewModel.question, "Рейтинг этого фильма больше чем 6?")
    }
}
