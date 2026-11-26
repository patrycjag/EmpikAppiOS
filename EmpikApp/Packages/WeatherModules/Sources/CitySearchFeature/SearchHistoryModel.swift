import Domain
import Foundation
import Observation
import OSLog

@MainActor
@Observable
public final class SearchHistoryModel {
    public private(set) var items: [Location] = []

    @ObservationIgnored private var pendingTask: Task<Void, Never>?
    private let store: any SearchHistoryStoring

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherModules", category: "SearchHistory")

    public init(store: any SearchHistoryStoring) {
        self.store = store
    }

    public func load() async {
        await perform("Loading history failed") { store in
            try await store.load()
        }.value
    }

    public func add(_ location: Location) {
        perform("Saving history failed") { store in
            try await store.add(location)
        }
    }

    public func remove(_ locations: [Location]) {
        let ids = Set(locations.map(\.id))
        guard !ids.isEmpty else { return }
        items.removeAll { ids.contains($0.id) }
        perform("Removing from history failed") { store in
            try await store.remove(locationIDs: ids)
        }
    }

    public func clear() {
        perform("Clearing history failed") { store in
            try await store.clear()
            return []
        }
    }

    @discardableResult
    private func perform(
        _ failureMessage: String,
        _ operation: @escaping @Sendable (any SearchHistoryStoring) async throws -> [Location]
    ) -> Task<Void, Never> {
        let previousTask = pendingTask
        let store = store
        let task = Task {
            await previousTask?.value
            do {
                items = try await operation(store)
            } catch {
                Self.logger.error("\(failureMessage, privacy: .public): \(error.localizedDescription, privacy: .public)")
                // Re-sync with what is actually stored, e.g. after an optimistic removal failed.
                if let stored = try? await store.load() {
                    items = stored
                }
            }
        }
        pendingTask = task
        return task
    }
}
