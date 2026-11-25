import Foundation

public enum NetworkError: LocalizedError, Equatable, Sendable {
    case offline
    case general(message: String)

    public var errorDescription: String? {
        switch self {
        case .offline:
            "Brak połączenia z internetem."
        case let .general(message):
            message
        }
    }
}
