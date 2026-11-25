import Foundation

public protocol RequestBuilding: Sendable {
    func makeRequest(for endpoint: Endpoint) throws -> URLRequest
}

public struct URLRequestBuilder: RequestBuilding {
    public init() {}

    public func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.general(message: "Nieprawidłowy adres zapytania.")
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems.map { URLQueryItem(name: $0.name, value: $0.value) }
        }
        guard let resolvedURL = components.url else {
            throw NetworkError.general(message: "Nieprawidłowy adres zapytania.")
        }

        var request = URLRequest(url: resolvedURL, timeoutInterval: endpoint.timeout)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
