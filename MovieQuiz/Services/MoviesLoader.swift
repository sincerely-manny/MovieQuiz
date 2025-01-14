import Foundation

protocol MoviesLoading {
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
  private enum MoviesLoaderError: Error {
    case decodingError
  }

  // MARK: - NetworkClient
  private let networkClient = NetworkClient()

  // MARK: - URL
  private var mostPopularMoviesUrl: URL {
    guard
      let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf")
    else {
      preconditionFailure("Unable to construct mostPopularMoviesUrl")
    }
    return url
  }

  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
  {
    networkClient.fetch(url: mostPopularMoviesUrl) { result in
      switch result {
      case .success(let encoded):
        do {
          let mostPopularMovies = try JSONDecoder().decode(
            MostPopularMovies.self, from: encoded)
          handler(.success(mostPopularMovies))
        } catch {
          handler(.failure(error))
        }
      case .failure(let error):
        handler(.failure(error))
      }
    }
  }
}
