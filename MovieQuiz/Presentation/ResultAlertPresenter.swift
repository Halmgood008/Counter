import UIKit


final class ResultAlertPresenter {
    private var actionHandler: (() -> Void)?
        
    func showAlert(on viewController: UIViewController, with model: AlertModel, completion: @escaping () -> Void) {
        self.actionHandler = completion
            
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
            
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            self?.actionHandler?()
        }
            
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}
