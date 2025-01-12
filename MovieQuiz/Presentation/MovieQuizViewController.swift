import UIKit

struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
}

struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

private let questions: [QuizQuestion] = [
  QuizQuestion(
    image: "The Godfather",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
  QuizQuestion(
    image: "The Dark Knight",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
  QuizQuestion(
    image: "Kill Bill",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
  QuizQuestion(
    image: "The Avengers",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
  QuizQuestion(
    image: "Deadpool",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
  QuizQuestion(
    image: "The Green Knight",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
  QuizQuestion(
    image: "Old",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
  QuizQuestion(
    image: "The Ice Age Adventures of Buck Wild",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
  QuizQuestion(
    image: "Tesla",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
  QuizQuestion(
    image: "Vivarium",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
]

final class MovieQuizViewController: UIViewController {
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  
  private var buttonsEnabled = true

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var textLabel: UILabel!
  @IBOutlet private var counterLabel: UILabel!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    currentQuestionIndex = -1
    showNextQuestionOrResults()
    imageView.layer.masksToBounds = true
    super.viewDidLoad()
  }

  private func convert(model: QuizQuestion) -> QuizStepViewModel {
    guard let image = UIImage(named: model.image) else {
      fatalError("Image is nil")
    }

    return QuizStepViewModel(
      image: image,
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
    )
  }

  private func show(quiz step: QuizStepViewModel) {
    imageView.image = step.image
    textLabel.text = step.question
    counterLabel.text = step.questionNumber
  }

  private func show(quiz result: QuizResultsViewModel) {
    let action = UIAlertAction(title: result.buttonText, style: .default) {
      _ in
      self.currentQuestionIndex = -1
      self.correctAnswers = 0
      self.showNextQuestionOrResults()
    }
    let alert = UIAlertController(
      title: result.title,
      message: result.text,
      preferredStyle: .alert)
    alert.addAction(action)
    self.present(alert, animated: true, completion: nil)
  }

  private func showAnswerResult(isCorrect: Bool) {
    buttonsEnabled = false
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor =
      isCorrect ? UIColor.ypxGreen.cgColor : UIColor.ypxRed.cgColor

    if isCorrect {
      correctAnswers += 1
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.imageView.layer.borderColor = UIColor.clear.cgColor
      self.showNextQuestionOrResults()
      self.buttonsEnabled = true
    }
  }

  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    guard buttonsEnabled == true else { return }
    
    showAnswerResult(
      isCorrect: questions[currentQuestionIndex].correctAnswer == true)
  }

  @IBAction private func noButtonClicked(_ sender: UIButton) {
    guard buttonsEnabled == true else { return }
    
    showAnswerResult(
      isCorrect: questions[currentQuestionIndex].correctAnswer == false)
  }

  private func showNextQuestionOrResults() {
    if currentQuestionIndex == questions.count - 1 {
      let result = QuizResultsViewModel(
        title: "Этот раунд окончен!",
        text: "Ваш результат \(correctAnswers)/\(questions.count)",
        buttonText: "Сыграть ещё раз"
      )
      show(quiz: result)
    } else {
      currentQuestionIndex += 1
      let nextQuestion = questions[currentQuestionIndex]
      let viewModel = convert(model: nextQuestion)
      show(quiz: viewModel)
    }
  }

}
