import Foundation
import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
  private let moviesLoader: MoviesLoading
  private weak var delegate: QuestionFactoryDelegate?
  private var movies: [MostPopularMovie] = []

  private enum QuestionFactoryError: Error, LocalizedError {
      case imageLoadingFailed
    
      var errorDescription: String? {
          switch self {
          case .imageLoadingFailed:
              return NSLocalizedString("Error loading image", comment: "Error loading image")
          }
      }
  }

  init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
    self.loadData()
  }

  func loadData() {
    moviesLoader.loadMovies { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch result {
        case .success(let mostPopularMovies):
          self.movies = mostPopularMovies.items
          self.delegate?.didLoadDataFromServer()
        case .failure(let error):
          self.delegate?.didFailToLoadData(with: error)
        }
      }
    }
  }

  func requestNextQuestion() {
    if movies.isEmpty {
      loadData()
      return
    }

    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      let index = (0..<self.movies.count).randomElement() ?? 0

      guard let movie = self.movies[safe: index] else { return }

      var imageData = Data()

      do {
        imageData = try Data(contentsOf: movie.resizedImageURL)
      } catch {
        self.delegate?.didFailToLoadData(with: error)
        return
      }

      DispatchQueue.main.async { [weak self] in

        if UIImage(data: imageData) == nil { // check wheher it's actually an image
          self?.delegate?.didFailToLoadData(with: QuestionFactoryError.imageLoadingFailed)
          return
        }

        let rating = Float(movie.rating) ?? 0

        var suggestedRating: Int
        repeat {
          suggestedRating = Int.random(in: 3...8)
        } while Float(suggestedRating) == rating

        let isMore = Int.random(in: 0...1) == 1
        let text =
          "Рейтинг этого фильма \(isMore ? "больше" : "меньше") чем \(suggestedRating)?"
        let correctAnswer =
          isMore
          ? rating > Float(suggestedRating) : rating < Float(suggestedRating)

        let question = QuizQuestion(
          image: imageData,
          text: text,
          correctAnswer: correctAnswer)
        guard let self = self else { return }
        self.delegate?.didReceiveNextQuestion(question: question)
      }
    }
  }
}
