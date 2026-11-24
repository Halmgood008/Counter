import Foundation


protocol MovieQuizViewProtocol: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func show(quiz step: QuizStepViewModel)
    func showFinalResults(with model: AlertModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
}
