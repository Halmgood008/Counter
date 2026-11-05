import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var textLabel: UILabel?
    @IBOutlet private weak var counterLabel: UILabel?
    @IBOutlet private weak var yesButton: UIButton?
    @IBOutlet private weak var noButton: UIButton?
    
    // MARK: - Constants
    private let alertTitle = "Этот раунд окончен!"
    private let alertButtonText = "Сыграть ещё раз"
    private let totalQuestions = 10
    
    // Сервисы
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let alertPresenter = ResultAlertPresenter()
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()

    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImage()
        showCurrentQuestion()
    }
    
    // MARK: - Setup
    private func configureImage() {
        imageView?.layer.cornerRadius = 20
        imageView?.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        checkAnswer(userAnswer: true)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        checkAnswer(userAnswer: false)
    }
    
    // MARK: - Logic
    private func showCurrentQuestion() {
        guard let question = questionFactory.requestQuestion() else {
            showFinalResults()
            return
        }
        
        self.currentQuestion = question
        
        imageView?.image = UIImage(named: question.image)
        textLabel?.text = question.text
        counterLabel?.text = "\(questionFactory.currentIndex)/\(totalQuestions)"
                
        yesButton?.isEnabled = true
        noButton?.isEnabled = true
    }
    
    private func checkAnswer(userAnswer: Bool) {
        yesButton?.isEnabled = false
        noButton?.isEnabled = false
        
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = (userAnswer == currentQuestion.correctAnswer)
        
        imageView?.layer.borderWidth = 8
        let borderColor = isCorrect ? UIColor(named: "YP Green") : UIColor(named: "YP Red")
        imageView?.layer.borderColor = borderColor?.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.imageView?.layer.borderWidth = 0
            self.showCurrentQuestion()
        }
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
            title: alertTitle,
            message: message,
            buttonText: alertButtonText
        )
                
        alertPresenter.showAlert(on: self, with: model) { [weak self] in
            self?.correctAnswers = 0
            self?.questionFactory.reset()
            self?.showCurrentQuestion()
        }
    }
}
