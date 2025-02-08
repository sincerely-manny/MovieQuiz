import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {  
  var buttonsEnabled = true

  private var alertPresenter: AlertPresenterProtocol?
  private let statisticService: StatisticServiceProtocol = StatisticService()
  private var presenter: MovieQuizPresenter!
  private var loadingView: LoadingView!

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var textLabel: UILabel!
  @IBOutlet private var counterLabel: UILabel!

  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    guard buttonsEnabled else { return }
    presenter.yesButtonClicked()
  }

  @IBAction private func noButtonClicked(_ sender: UIButton) {
    guard buttonsEnabled else { return }
    presenter.noButtonClicked()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    presenter = MovieQuizPresenter(viewController: self)
    alertPresenter = AlertPresenter(delegate: presenter, viewController: self)
    loadingView = LoadingView(parent: view)
    showLoadingIndicator()
  }

  func show(quiz step: QuizStepViewModel) {
    imageView.image = step.image
    textLabel.text = step.question
    counterLabel.text = step.questionNumber
  }

  func show(quiz result: QuizResultsViewModel) {
    let model = AlertModel(
      title: result.title, message: result.text,
      buttonText: result.buttonText)
    alertPresenter?.present(model: model)
  }

  func highlightImageBorder(isCorrectAnswer: Bool) {
    imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
  }
  
  func unhighlightImageBorder() {
    imageView.layer.borderColor = UIColor.clear.cgColor
  }

  

  internal func showLoadingIndicator() {
    loadingView.show()
  }

  internal func hideLoadingIndicator() {
    loadingView.hide()
  }

  func showNetworkError(message: String) {
    hideLoadingIndicator()

    let model = AlertModel(
      title: "Ошибка",
      message: message,
      buttonText: "Попробовать еще раз"
    )

    alertPresenter?.present(model: model)
  }

}

protocol MovieQuizViewControllerProtocol: AnyObject {
    var buttonsEnabled: Bool { get set }
  
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func unhighlightImageBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
