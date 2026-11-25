import Foundation

public protocol LocationSearching: Sendable {
    func searchLocations(named query: String) async throws -> [Location]
}
