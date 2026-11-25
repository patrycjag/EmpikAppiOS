import Foundation

public protocol LocationSearching: Sendable {
    func searchLocations(named query: String) async throws -> [Location]
}

public protocol SearchHistoryStoring: Sendable {
    func load() async throws -> [Location]
    func add(_ location: Location) async throws -> [Location]
    func remove(locationID: Location.ID) async throws -> [Location]
    func clear() async throws
}
