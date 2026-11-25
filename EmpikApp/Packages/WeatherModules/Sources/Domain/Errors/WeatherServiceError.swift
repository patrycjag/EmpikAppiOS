import Foundation

public enum WeatherServiceError: LocalizedError, Equatable, Sendable {
    case offline
    case general(message: String)

    public init(_ error: any Error) {
        self = (error as? WeatherServiceError) ?? .general(message: error.localizedDescription)
    }

    public var message: String {
        switch self {
        case .offline:
            "Brak połączenia z internetem."
        case let .general(message):
            message
        }
    }

    public var errorDescription: String? {
        message
    }
}
