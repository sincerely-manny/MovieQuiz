import UIKit

final class MovieQuizPresenter {
  private let questionsAmount: Int = 10
  private var currentQuestionIndex: Int = 0
  private var currentQuestion: QuizQuestion?
  private var correctAnswers: Int = 0
  private weak var viewController: MovieQuizViewControllerProtocol?
  private let statisticService: StatisticServiceProtocol = StatisticService()
  private var questionFactory: QuestionFactoryProtocol?

  init(viewController: MovieQuizViewControllerProtocol) {
    self.viewController = viewController
    questionFactory = QuestionFactory(
      moviesLoader: MoviesLoader(),
      delegate: self
    )
  }
  
  func yesButtonClicked() {
    didAnswer(isYes: true)
  }
  
  func noButtonClicked() {
    didAnswer(isYes: false)
  }

  private func didAnswer(isYes: Bool) {
    viewController?.buttonsEnabled = false
    guard let currentQuestion = currentQuestion else {
      return
    }
    let givenAnswer = isYes
    let isCorrectAnswerGiven = givenAnswer == currentQuestion.correctAnswer

    if isCorrectAnswerGiven {
      correctAnswers += 1
    }
    showAnswerResult(isCorrect: isCorrectAnswerGiven)
  }

  func convert(model: QuizQuestion) -> QuizStepViewModel {
    QuizStepViewModel(
      image: UIImage(data: model.image) ?? UIImage(),
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
    )
  }

  private func isLastQuestion() -> Bool {
    currentQuestionIndex == questionsAmount - 1
  }

  private func restartGame() {
    correctAnswers = 0
    currentQuestionIndex = -1
    viewController?.buttonsEnabled = true
    showNextQuestionOrResults()
  }

  private func switchToNextQuestion() {
    currentQuestionIndex += 1
  }

  private func showAnswerResult(isCorrect: Bool) {
    viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      viewController?.unhighlightImageBorder()
      showNextQuestionOrResults()
    }
  }
  
  private func showNextQuestionOrResults() {
    if isLastQuestion() {
      statisticService.store(
        correct: correctAnswers, total: questionsAmount)

      let result = QuizResultsViewModel(
        title: "Этот раунд окончен!",
        text: """
          Ваш результат: \(correctAnswers)/\(questionsAmount)
          Количество сыгранных квизов: \(statisticService.gamesCount)
          Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
          """,
        buttonText: "Сыграть ещё раз"
      )
      viewController?.show(quiz: result)
    } else {
      switchToNextQuestion()
      questionFactory?.requestNextQuestion()
      viewController?.showLoadingIndicator()
    }
  }

}

extension MovieQuizPresenter: QuestionFactoryDelegate {
  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question = question else {
      return
    }

    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.viewController?.show(quiz: viewModel)
      self.viewController?.hideLoadingIndicator()
      self.viewController?.buttonsEnabled = true
    }
  }

  func didLoadDataFromServer() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      viewController?.hideLoadingIndicator()
      self.viewController?.buttonsEnabled = true
    }
    restartGame()
  }

  func didFailToLoadData(with error: Error) {
    viewController?.showNetworkError(message: error.localizedDescription)
  }
}

extension MovieQuizPresenter: AlertPresenterDelegate {
  func didFinishPresentingAlert() {
    restartGame()
  }
}
