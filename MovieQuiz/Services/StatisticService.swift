import Foundation

final class StatisticService: StatisticServiceProtocol {
  private let storage: UserDefaults = .standard

  private enum Keys: String {
    case correct
    case bestGameTotal
    case bestGameDate
    case bestGameCorrect
    case gamesCount
  }

  var gamesCount: Int {
    get {
      storage.integer(forKey: Keys.gamesCount.rawValue)
    }
    set {
      storage.set(newValue, forKey: Keys.gamesCount.rawValue)
    }
  }

  private var correctCount: Int {
    get {
      storage.integer(forKey: Keys.correct.rawValue)
    }
    set {
      storage.set(newValue, forKey: Keys.correct.rawValue)
    }
  }

  var bestGame: GameResult {
    get {
      let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
      let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
      let date =
        storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
      return GameResult(correct: correct, total: total, date: date)
    }
    set {
      storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
      storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
      storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
    }
  }

  var totalAccuracy: Double {
    gamesCount == 0 ? 0 : (Double(correctCount) / Double(gamesCount * 10)) * 100
  }

  func store(correct count: Int, total amount: Int) {
    gamesCount += 1
    correctCount += count
    let newGameResult = GameResult(correct: count, total: amount, date: Date())
    bestGame = bestGame.isBetterThan(newGameResult) ? bestGame : newGameResult
  }

}
