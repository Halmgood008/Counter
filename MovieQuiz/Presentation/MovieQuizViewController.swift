import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Services
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let moviesLoader: MoviesLoaderProtocol = MoviesLoader()
    private let imageLoader: ImageLoaderProtocol = ImageLoader()
    
    private lazy var presenter: MovieQuizPresenter = {
        let questionFactory = QuestionFactory(moviesLoader: moviesLoader)
        let presenter = MovieQuizPresenter(questionFactory: questionFactory, statisticService: statisticService)
        presenter.view = self
        return presenter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImage()
        setupActivityIndicator()
        presenter.viewDidLoad()
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
    
    private func configureImage() {
        imageView?.layer.cornerRadius = 20
        imageView?.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        yesButton?.isEnabled = false
        noButton?.isEnabled = false
        presenter.didAnswer(isYes: true)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        yesButton?.isEnabled = false
        noButton?.isEnabled = false
        presenter.didAnswer(isYes: false)
    }
    
    // MARK: - MovieQuizViewProtocol Implementation
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton?.isEnabled = false
        noButton?.isEnabled = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        )
        
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            self?.presenter.viewDidLoad()
        })
        self.present(alert, animated: true)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView?.alpha = 0.0
        imageView?.image = nil
        
        textLabel?.text = step.question
        counterLabel?.text = step.questionNumber
        imageView?.layer.borderWidth = 0
        
        imageLoader.loadImage(urlString: step.image) { [weak self] image in
            guard let self = self else { return }
            
            self.imageView?.alpha = 1.0
            self.imageView?.image = image ?? UIImage(systemName: "photo")
            
            self.yesButton?.isEnabled = true
            self.noButton?.isEnabled = true
        }
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView?.layer.borderWidth = 8
        let borderColor = isCorrectAnswer ? UIColor(named: "YP Green") : UIColor(named: "YP Red")
        imageView?.layer.borderColor = borderColor?.cgColor
    }
    
    func showFinalResults(with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        })
        self.present(alert, animated: true)
    }
}
