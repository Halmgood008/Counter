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
    
    // MARK: - Properties
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
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
        guard currentQuestionIndex < questions.count else {
            showFinalResults()
            return
        }
        
        let question = questions[currentQuestionIndex]
        imageView?.image = UIImage(named: question.image)
        textLabel?.text = question.text
        counterLabel?.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        yesButton?.isEnabled = true
        noButton?.isEnabled = true
    }
    
    private func checkAnswer(userAnswer: Bool) {
        yesButton?.isEnabled = false
        noButton?.isEnabled = false
        
        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        let isCorrect = (userAnswer == correctAnswer)
        
        imageView?.layer.borderWidth = 8
        let borderColor = isCorrect ? UIColor(named: "YP Green") : UIColor(named: "YP Red")
        imageView?.layer.borderColor = borderColor?.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.imageView?.layer.borderWidth = 0
            self.currentQuestionIndex += 1
            self.showCurrentQuestion()
        }
    }
    
    private func showFinalResults() {
        let alert = UIAlertController(
            title: alertTitle,
            message: "Ваш результат: \(correctAnswers)/\(questions.count)",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: alertButtonText, style: .default) { [weak self] _ in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.showCurrentQuestion()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
}
