import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate,
  AlertPresenterDelegate
{
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  private let questionsAmount: Int = 10
  private var currentQuestion: QuizQuestion?

  private var buttonsEnabled = true

  private var questionFactory: QuestionFactoryProtocol?
  private var alertPresenter: AlertPresenterProtocol?
  private let statisticService: StatisticServiceProtocol = StatisticService()

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var textLabel: UILabel!
  @IBOutlet private var counterLabel: UILabel!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    questionFactory = QuestionFactory(delegate: self)
    alertPresenter = AlertPresenter(delegate: self)
    currentQuestionIndex = -1
    imageView.layer.masksToBounds = true
    showNextQuestionOrResults()
  }

  private func convert(model: QuizQuestion) -> QuizStepViewModel {
    guard let image = UIImage(named: model.image) else {
      fatalError("Image is nil")
    }

    return QuizStepViewModel(
      image: image,
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
    )
  }

  private func show(quiz step: QuizStepViewModel) {
    imageView.image = step.image
    textLabel.text = step.question
    counterLabel.text = step.questionNumber
  }

  private func show(quiz result: QuizResultsViewModel) {
    let model = AlertModel(
      title: result.buttonText, message: result.text,
      buttonText: result.buttonText)
    alertPresenter?.present(model: model)
  }

  private func showAnswerResult(isCorrect: Bool) {
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor =
      isCorrect ? UIColor.ypxGreen.cgColor : UIColor.ypxRed.cgColor

    if isCorrect {
      correctAnswers += 1
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      self.imageView.layer.borderColor = UIColor.clear.cgColor
      self.showNextQuestionOrResults()
    }
  }

  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    guard buttonsEnabled == true else { return }
    buttonsEnabled = false
    guard let currentQuestion = currentQuestion else {
      return
    }
    showAnswerResult(
      isCorrect: currentQuestion.correctAnswer == true)
  }

  @IBAction private func noButtonClicked(_ sender: UIButton) {
    guard buttonsEnabled == true else { return }
    buttonsEnabled = false
    guard let currentQuestion = currentQuestion else {
      return
    }
    showAnswerResult(
      isCorrect: currentQuestion.correctAnswer == false)
  }

  private func showNextQuestionOrResults() {
    if currentQuestionIndex == questionsAmount - 1 {
      statisticService.store(correct: correctAnswers, total: questionsAmount)

      let result = QuizResultsViewModel(
        title: "Этот раунд окончен!",
        text: """
          Количество сыгранных квизов: \(statisticService.gamesCount) 
          Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
          """,
        buttonText: "Сыграть ещё раз"
      )
      show(quiz: result)
    } else {
      currentQuestionIndex += 1
      questionFactory?.requestNextQuestion()
    }
  }

  // MARK: - QuestionFactoryDelegate

  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question else { return }

    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.show(quiz: viewModel)
      self?.buttonsEnabled = true
    }
  }

  // MARK: - AlertPresenterDelegate

  func didFinishPresentingAlert() {
    self.currentQuestionIndex = -1
    self.correctAnswers = 0
    self.showNextQuestionOrResults()
    buttonsEnabled = true
  }

}
