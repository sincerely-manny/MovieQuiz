import UIKit

class AlertPresenter: AlertPresenterProtocol {
  private weak var delegate: AlertPresenterDelegate?

  init(delegate: AlertPresenterDelegate?) {
    self.delegate = delegate
  }

  func present(model: AlertModel) {
    let action = UIAlertAction(title: model.buttonText, style: .default) {
      [weak self] _ in
      self?.delegate?.didFinishPresentingAlert()
    }
    
    let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
    alert.addAction(action)
    delegate?.present(alert, animated: true, completion: nil)
  }
}
