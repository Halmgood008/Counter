import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Constants
    private let alertTitle = "Этот раунд окончен!"
    private let alertButtonText = "Сыграть ещё раз"
    private let totalQuestions = 10
    
    // MARK: - Services
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let alertPresenter = ResultAlertPresenter()
    
    private let moviesLoader: MoviesLoaderProtocol = MoviesLoader()
    private let imageLoader: ImageLoaderProtocol = ImageLoader()
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(moviesLoader: moviesLoader)
    }()
    
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImage()
        setupActivityIndicator()
        showLoadingIndicator()
        loadData()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Setup
    private func configureImage() {
        imageView?.layer.cornerRadius = 20
        imageView?.layer.masksToBounds = true
    }
    
    // MARK: - Loading Indicator
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton?.isEnabled = false
        noButton?.isEnabled = false
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        checkAnswer(userAnswer: true)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        checkAnswer(userAnswer: false)
    }
    
    // MARK: - Logic
    private func loadData() {
        questionFactory.loadData { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.showCurrentQuestion()
            case .failure:
                self.activityIndicator.stopAnimating()
                self.showNetworkErrorAlert()
            }
        }
    }
    
    private func showNetworkErrorAlert() {
        let model = AlertModel(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробуйте ещё раз.",
            buttonText: "Попробовать ещё раз"
        )
        alertPresenter.showAlert(on: self, with: model) { [weak self] in
            self?.showLoadingIndicator()
            self?.loadData()
        }
    }
    
    private func showCurrentQuestion() {
        guard let question = questionFactory.requestQuestion() else {
            showFinalResults()
            return
        }
        
        self.currentQuestion = question
        
        showLoadingIndicator()
        
        imageView?.alpha = 0.0
        imageView?.image = nil
        
        textLabel?.text = question.text
        counterLabel?.text = "\(questionFactory.currentIndex)/\(totalQuestions)"
        
        imageLoader.loadImage(urlString: question.image) { [weak self] image in
            guard let self = self else { return }
            
            self.imageView?.alpha = 1.0
            self.imageView?.image = image ?? UIImage(systemName: "photo")

            self.activityIndicator.stopAnimating()
            self.yesButton?.isEnabled = true
            self.noButton?.isEnabled = true
        }
    }
    
    private func checkAnswer(userAnswer: Bool) {
        guard yesButton?.isEnabled == true else { return }
        
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
            guard let self = self else { return }
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
            guard let self = self else { return }
            self.correctAnswers = 0
            self.questionFactory.reset()
            self.showCurrentQuestion()
        }
    }
}
