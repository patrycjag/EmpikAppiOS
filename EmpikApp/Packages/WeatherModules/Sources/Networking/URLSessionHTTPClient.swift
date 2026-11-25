import Foundation

public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func perform(_ request: URLRequest) async throws -> HTTPResponse {
        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: request)
        } catch {
            throw Self.map(error)
        }

        let (data, response) = result
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.general(message: "Nieprawidłowa odpowiedź serwera.")
        }
        return HTTPResponse(statusCode: httpResponse.statusCode, data: data)
    }

    static func map(_ error: any Error) -> any Error {
        if error is CancellationError {
            return error
        }
        guard let urlError = error as? URLError else {
            return NetworkError.general(message: error.localizedDescription)
        }

        switch urlError.code {
        case .cancelled:
            return CancellationError()
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return NetworkError.offline
        default:
            return NetworkError.general(message: urlError.localizedDescription)
        }
    }
}
