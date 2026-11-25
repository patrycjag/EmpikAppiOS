import Domain
import Networking

extension WeatherServiceError {
    init(networkError: NetworkError) {
        switch networkError {
        case .offline:
            self = .offline
        case let .general(message):
            self = .general(message: message)
        }
    }
}
