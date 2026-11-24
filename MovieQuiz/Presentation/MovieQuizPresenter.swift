import Foundation

final class MovieQuizPresenter {
    weak var view: MovieQuizViewProtocol?
    
    private let questionFactory: QuestionFactoryProtocol
    private let statisticService: StatisticServiceProtocol
    
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private let totalQuestions = 10
    
    init(questionFactory: QuestionFactoryProtocol, statisticService: StatisticServiceProtocol) {
        self.questionFactory = questionFactory
        self.statisticService = statisticService
    }
    
    func viewDidLoad() {
        view?.showLoadingIndicator()
        
        questionFactory.loadData { [weak self] result in
            guard let self = self else { return }
            
            self.view?.hideLoadingIndicator()
            
            switch result {
            case .success:
                self.showNextQuestion()
            case .failure:
                self.view?.showNetworkError(message: "Что-то пошло не так. Попробуйте ещё раз.")
            }
        }
    }
    

    private func showNextQuestion() {
        guard let question = questionFactory.requestQuestion() else {
            showFinalResults()
            return
        }
        
        self.currentQuestion = question
        
        let viewModel = convert(model: question)
        view?.show(quiz: viewModel)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = (isYes == currentQuestion.correctAnswer)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        view?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestion()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(questionFactory.currentIndex)/\(totalQuestions)"
        )
    }
    
    private func showFinalResults() {
        statisticService.saveResult(correct: correctAnswers, total: totalQuestions)
        
        let bestGame = statisticService.bestGame
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        let dateString = dateFormatter.string(from: bestGame.date)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(totalQuestions)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        let model = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз"
        )
        
        view?.showFinalResults(with: model)
    }
    
    func restartGame() {
        correctAnswers = 0
        questionFactory.reset()
        showNextQuestion()
    }
}
