import Foundation

public struct Endpoint: Equatable, Sendable {
    public struct QueryItem: Equatable, Sendable {
        public let name: String
        public let value: String

        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }
    }

    public let baseURL: URL
    public let path: String
    public let queryItems: [QueryItem]
    public let timeout: TimeInterval

    public init(baseURL: URL, path: String, queryItems: [QueryItem] = [], timeout: TimeInterval = 15) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
        self.timeout = timeout
    }
}
