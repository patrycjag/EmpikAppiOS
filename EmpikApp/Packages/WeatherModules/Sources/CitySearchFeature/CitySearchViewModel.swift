import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class CitySearchViewModel {
    public enum State: Equatable {
        case idle
        case tooShort(minimumLength: Int)
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

    private var retryAttempt = 0
    @ObservationIgnored private var handledRetryAttempt = 0

    private let locationSearch: any LocationSearching
    private let debounceDuration: Duration

    var searchKey: SearchKey {
        SearchKey(query: query, attempt: retryAttempt)
    }

    public init(
        locationSearch: any LocationSearching,
        debounceDuration: Duration = .milliseconds(350)
    ) {
        self.locationSearch = locationSearch
        self.debounceDuration = debounceDuration
    }

    public func search() async {
        let isRetry = retryAttempt != handledRetryAttempt
        handledRetryAttempt = retryAttempt

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            state = .idle
            return
        }
        guard trimmedQuery.count >= Self.minimumQueryLength else {
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
        await performSearch(for: trimmedQuery)
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
}
