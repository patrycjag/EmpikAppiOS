import Domain
import Foundation
import Observation
import OSLog

@MainActor
@Observable
public final class CitySearchViewModel {
    public enum State: Equatable {
        case idle
        case tooShort(minimumLength: Int)
        case invalid(CityNameValidator.Failure)
        case loading
        case results([Location])
        case empty(query: String)
        case failure(WeatherServiceError)
    }

    struct SearchKey: Hashable {
        let query: String
        let attempt: Int
    }

    public static let minimumQueryLength = 2

    public var query = ""
    public private(set) var state: State = .idle
    public private(set) var history: [Location] = []

    private var retryAttempt = 0
    @ObservationIgnored private var handledRetryAttempt = 0
    @ObservationIgnored private var historyTask: Task<Void, Never>?

    private let locationSearch: any LocationSearching
    private let historyStore: any SearchHistoryStoring
    private let validator: CityNameValidator
    private let debounceDuration: Duration

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherModules", category: "CitySearch")

    var searchKey: SearchKey {
        SearchKey(query: query, attempt: retryAttempt)
    }

    public init(
        locationSearch: any LocationSearching,
        historyStore: any SearchHistoryStoring,
        validator: CityNameValidator = CityNameValidator(),
        debounceDuration: Duration = .milliseconds(350)
    ) {
        self.locationSearch = locationSearch
        self.historyStore = historyStore
        self.validator = validator
        self.debounceDuration = debounceDuration
    }

    public func search() async {
        let isRetry = retryAttempt != handledRetryAttempt
        handledRetryAttempt = retryAttempt

        switch validator.validate(query) {
        case .empty:
            state = .idle

        case let .invalid(failure):
            state = .invalid(failure)

        case let .valid(normalizedQuery):
            guard normalizedQuery.count >= Self.minimumQueryLength else {
                state = .tooShort(minimumLength: Self.minimumQueryLength)
                return
            }
            if !isRetry {
                do {
                    try await Task.sleep(for: debounceDuration)
                } catch {
                    return
                }
            }
            await performSearch(for: normalizedQuery)
        }
    }

    public func retry() {
        retryAttempt += 1
    }

    private func performSearch(for query: String) async {
        state = .loading
        do {
            let locations = try await locationSearch.searchLocations(named: query)
            guard !Task.isCancelled else { return }
            state = locations.isEmpty ? .empty(query: query) : .results(locations)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            state = .failure(WeatherServiceError(error))
        }
    }

    public func loadHistory() async {
        do {
            history = try await historyStore.load()
        } catch {
            Self.logger.error("Loading history failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func select(_ location: Location) {
        updateHistory(failureMessage: "Saving history failed") { store in
            try await store.add(location)
        }
    }

    public func removeFromHistory(_ locations: [Location]) {
        let ids = Set(locations.map(\.id))
        guard !ids.isEmpty else { return }
        history.removeAll { ids.contains($0.id) }
        updateHistory(failureMessage: "Removing from history failed") { store in
            var updated: [Location] = []
            for id in ids {
                updated = try await store.remove(locationID: id)
            }
            return updated
        }
    }

    public func clearHistory() {
        updateHistory(failureMessage: "Clearing history failed") { store in
            try await store.clear()
            return []
        }
    }

    private func updateHistory(
        failureMessage: String,
        _ operation: @escaping @Sendable (any SearchHistoryStoring) async throws -> [Location]
    ) {
        let previousTask = historyTask
        let store = historyStore
        historyTask = Task {
            await previousTask?.value
            do {
                history = try await operation(store)
            } catch {
                Self.logger.error("\(failureMessage, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
