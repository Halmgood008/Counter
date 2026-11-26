import XCTest
@testable import MovieQuiz

final class MockQuestionFactory: QuestionFactoryProtocol {
    var currentIndex: Int = 1
    
    func loadData(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    func requestQuestion() -> QuizQuestion? {
        return nil
    }
    
    func reset() {}
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testConvertModel() {
        // Given
        let mockFactory = MockQuestionFactory()
        let statisticService = StatisticService()
        let presenter = MovieQuizPresenter(questionFactory: mockFactory, statisticService: statisticService)
        
        let question = QuizQuestion(
            image: "https://example.com/image.jpg",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        )
        
        // When
        let viewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertEqual(viewModel.image, question.image)
        XCTAssertEqual(viewModel.question, question.text)
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
