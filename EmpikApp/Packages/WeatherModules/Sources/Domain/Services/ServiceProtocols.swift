import Foundation

public protocol LocationSearching: Sendable {
    func searchLocations(named query: String) async throws -> [Location]
}

public protocol ForecastProviding: Sendable {
    func forecast(for location: Location) async throws -> Forecast
    func dailyForecast(for location: Location, days: Int) async throws -> [DailyForecast]
}

public protocol SearchHistoryStoring: Sendable {
    func load() async throws -> [Location]
    func add(_ location: Location) async throws -> [Location]
    func remove(locationIDs: Set<Location.ID>) async throws -> [Location]
    func clear() async throws
}
