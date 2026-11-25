import Foundation

public struct HTTPResponse: Sendable {
    public let statusCode: Int
    public let data: Data

    public init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }
}

public protocol HTTPClient: Sendable {
    func perform(_ request: URLRequest) async throws -> HTTPResponse
}

public extension HTTPClient {
    func get<Response: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as type: Response.Type = Response.self,
        requestBuilder: any RequestBuilding = URLRequestBuilder()
    ) async throws -> Response {
        let request = try requestBuilder.makeRequest(for: endpoint)
        let response = try await perform(request)

        guard (200..<300).contains(response.statusCode) else {
            throw NetworkError.general(message: "Serwer zwrócił błąd (kod \(response.statusCode)).")
        }

        do {
            return try JSONDecoder().decode(Response.self, from: response.data)
        } catch {
            throw NetworkError.general(message: "Nie udało się odczytać odpowiedzi serwera.")
        }
    }
}
