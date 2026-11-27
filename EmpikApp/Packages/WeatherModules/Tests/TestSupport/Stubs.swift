import Domain
import Foundation
import Networking

public final class LocationSearchStub: LocationSearching {
    public let result: LockIsolated<Result<[Location], any Error>>
    public let queries = LockIsolated<[String]>([])

    public init(result: Result<[Location], any Error> = .success([])) {
        self.result = LockIsolated(result)
    }

    public func searchLocations(named query: String) async throws -> [Location] {
        queries.withValue { $0.append(query) }
        return try result.value.get()
    }
}

public final class ForecastProviderStub: ForecastProviding {
    public let forecastResult: LockIsolated<Result<Forecast, any Error>>
    public let dailyResult: LockIsolated<Result<[DailyForecast], any Error>>
    public let forecastRequests = LockIsolated<[Location]>([])
    public let dailyRequests = LockIsolated<[Int]>([])

    public init(
        forecast: Result<Forecast, any Error> = .success(Fixtures.forecast()),
        daily: Result<[DailyForecast], any Error> = .success(Fixtures.dailyForecasts())
    ) {
        forecastResult = LockIsolated(forecast)
        dailyResult = LockIsolated(daily)
    }

    public func forecast(for location: Location) async throws -> Forecast {
        forecastRequests.withValue { $0.append(location) }
        return try forecastResult.value.get()
    }

    public func dailyForecast(for location: Location, days: Int) async throws -> [DailyForecast] {
        dailyRequests.withValue { $0.append(days) }
        return try dailyResult.value.get()
    }
}

public actor InMemorySearchHistoryStore: SearchHistoryStoring {
    public enum Operation: Sendable {
        case load, add, remove, clear
    }

    public private(set) var items: [Location]
    public private(set) var removeCallCount = 0
    private var failingOperations: Set<Operation> = []

    public init(items: [Location] = []) {
        self.items = items
    }

    public func fail(_ operations: Operation...) {
        failingOperations = Set(operations)
    }

    public func load() throws -> [Location] {
        try check(.load)
        return items
    }

    public func add(_ location: Location) throws -> [Location] {
        try check(.add)
        items.removeAll { $0.id == location.id }
        items.insert(location, at: 0)
        return items
    }

    public func remove(locationIDs: Set<Location.ID>) throws -> [Location] {
        removeCallCount += 1
        try check(.remove)
        items.removeAll { locationIDs.contains($0.id) }
        return items
    }

    public func clear() throws {
        try check(.clear)
        items = []
    }

    private func check(_ operation: Operation) throws {
        if failingOperations.contains(operation) {
            throw TestError("\(operation) failed")
        }
    }
}

public final class HTTPClientStub: HTTPClient {
    public let response: LockIsolated<Result<HTTPResponse, any Error>>
    public let requests = LockIsolated<[URLRequest]>([])

    public init(response: Result<HTTPResponse, any Error>) {
        self.response = LockIsolated(response)
    }

    public convenience init(statusCode: Int = 200, json: String) {
        self.init(response: .success(HTTPResponse(statusCode: statusCode, data: Data(json.utf8))))
    }

    public var lastRequest: URLRequest? {
        requests.value.last
    }

    public func perform(_ request: URLRequest) async throws -> HTTPResponse {
        requests.withValue { $0.append(request) }
        return try response.value.get()
    }
}

public extension URLRequest {
    var queryParameters: [String: String] {
        guard
            let url,
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        else { return [:] }
        return Dictionary(items.map { ($0.name, $0.value ?? "") }, uniquingKeysWith: { _, last in last })
    }
}
