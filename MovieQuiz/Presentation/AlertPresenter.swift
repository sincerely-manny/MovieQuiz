import UIKit

final class AlertPresenter: AlertPresenterProtocol {
  private weak var delegate: AlertPresenterDelegate?
  private weak var viewController: UIViewController?

  init(delegate: AlertPresenterDelegate?, viewController: UIViewController?) {
    self.viewController = viewController
    self.delegate = delegate
  }

  func present(model: AlertModel) {
    let action = UIAlertAction(
      title: model.buttonText,
      style: .default
    ) { [weak self] _ in
      self?.delegate?.didFinishPresentingAlert()
    }

    let alert = UIAlertController(
      title: model.title,
      message: model.message,
      preferredStyle: .alert)

    alert.addAction(action)
    viewController?.present(alert, animated: true, completion: nil)
  }
}
