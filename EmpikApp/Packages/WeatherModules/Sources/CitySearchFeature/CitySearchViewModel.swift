import Domain
import Foundation
import Observation

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

    struct SearchRequest: Hashable {
        let query: String
        let attempt: Int

        var isRetry: Bool { attempt > 0 }
    }

    public var query = "" {
        didSet {
            if query != oldValue {
                retryAttempt = 0
            }
        }
    }

    public private(set) var state: State = .idle
    public let history: SearchHistoryModel

    private var retryAttempt = 0

    private let locationSearch: any LocationSearching
    private let validator: CityNameValidator
    private let debounceDuration: Duration

    var searchRequest: SearchRequest {
        SearchRequest(query: query, attempt: retryAttempt)
    }

    public init(
        locationSearch: any LocationSearching,
        historyStore: any SearchHistoryStoring,
        validator: CityNameValidator = CityNameValidator(),
        debounceDuration: Duration = .milliseconds(350)
    ) {
        self.locationSearch = locationSearch
        self.history = SearchHistoryModel(store: historyStore)
        self.validator = validator
        self.debounceDuration = debounceDuration
    }

    func search(_ request: SearchRequest) async {
        switch validator.validate(request.query) {
        case .empty:
            state = .idle

        case let .tooShort(minimumLength):
            state = .tooShort(minimumLength: minimumLength)

        case let .invalid(failure):
            state = .invalid(failure)

        case let .valid(normalizedQuery):
            if !request.isRetry {
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

    public func select(_ location: Location) {
        history.add(location)
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
