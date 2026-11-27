@testable import CitySearchFeature
import Domain
import TestSupport
import Testing

@MainActor
struct CitySearchViewModelTests {
    private func makeViewModel(
        search: LocationSearchStub = LocationSearchStub(),
        store: InMemorySearchHistoryStore = InMemorySearchHistoryStore(),
        debounce: Duration = .zero
    ) -> CitySearchViewModel {
        CitySearchViewModel(locationSearch: search, historyStore: store, debounceDuration: debounce)
    }

    private func search(_ query: String, in viewModel: CitySearchViewModel) async {
        viewModel.query = query
        await viewModel.search(viewModel.searchRequest)
    }

    @Test func startsIdle() {
        let viewModel = makeViewModel()

        #expect(viewModel.state == .idle)
        #expect(viewModel.query.isEmpty)
        #expect(viewModel.searchRequest == .init(query: "", attempt: 0))
    }

    @Test func emptyQueryIsIdle() async {
        let search = LocationSearchStub()
        let viewModel = makeViewModel(search: search)

        await self.search("   ", in: viewModel)

        #expect(viewModel.state == .idle)
        #expect(search.queries.value.isEmpty)
    }

    @Test func tooShortQueryIsNotSearched() async {
        let search = LocationSearchStub()
        let viewModel = makeViewModel(search: search)

        await self.search("W", in: viewModel)

        #expect(viewModel.state == .tooShort(minimumLength: 2))
        #expect(search.queries.value.isEmpty)
    }

    @Test func invalidQueriesAreNotSearched() async {
        let search = LocationSearchStub()
        let viewModel = makeViewModel(search: search)

        await self.search("Warszawa1", in: viewModel)
        #expect(viewModel.state == .invalid(.containsDigits))

        await self.search("Kraków!", in: viewModel)
        #expect(viewModel.state == .invalid(.containsInvalidCharacters))

        #expect(search.queries.value.isEmpty)
    }

    @Test func showsResults() async {
        let search = LocationSearchStub(result: .success([Fixtures.warsaw, Fixtures.krakow]))
        let viewModel = makeViewModel(search: search)

        await self.search("Warszawa", in: viewModel)

        #expect(viewModel.state == .results([Fixtures.warsaw, Fixtures.krakow]))
        #expect(search.queries.value == ["Warszawa"])
    }

    @Test func searchesWithNormalizedQuery() async {
        let search = LocationSearchStub(result: .success([Fixtures.warsaw]))
        let viewModel = makeViewModel(search: search)

        await self.search("  Nowy   Sącz ", in: viewModel)

        #expect(search.queries.value == ["Nowy Sącz"])
    }

    @Test func showsEmptyStateWithNormalizedQuery() async {
        let viewModel = makeViewModel(search: LocationSearchStub(result: .success([])))

        await self.search(" Atlantyda ", in: viewModel)

        #expect(viewModel.state == .empty(query: "Atlantyda"))
    }

    @Test func showsOfflineFailure() async {
        let viewModel = makeViewModel(search: LocationSearchStub(result: .failure(WeatherServiceError.offline)))

        await self.search("Warszawa", in: viewModel)

        #expect(viewModel.state == .failure(.offline))
    }

    @Test func wrapsUnknownErrors() async {
        let viewModel = makeViewModel(search: LocationSearchStub(result: .failure(TestError("Boom"))))

        await self.search("Warszawa", in: viewModel)

        #expect(viewModel.state == .failure(.general(message: "Boom")))
    }

    @Test func ignoresCancellationErrors() async {
        let viewModel = makeViewModel(search: LocationSearchStub(result: .failure(CancellationError())))

        await self.search("Warszawa", in: viewModel)

        #expect(viewModel.state == .loading)
    }

    @Test func cancelledDebounceDoesNotSearch() async {
        let search = LocationSearchStub(result: .success([Fixtures.warsaw]))
        let viewModel = makeViewModel(search: search, debounce: .seconds(60))
        viewModel.query = "Warszawa"
        let request = viewModel.searchRequest

        let task = Task { await viewModel.search(request) }
        task.cancel()
        await task.value

        #expect(viewModel.state == .idle)
        #expect(search.queries.value.isEmpty)
    }

    @Test func retrySkipsDebounce() async {
        let search = LocationSearchStub(result: .success([Fixtures.warsaw]))
        let viewModel = makeViewModel(search: search, debounce: .seconds(60))
        viewModel.query = "Warszawa"
        viewModel.retry()

        let clock = ContinuousClock()
        let start = clock.now
        await viewModel.search(viewModel.searchRequest)

        #expect(clock.now - start < .seconds(5))
        #expect(viewModel.state == .results([Fixtures.warsaw]))
    }

    @Test func retryChangesSearchRequest() {
        let viewModel = makeViewModel()
        viewModel.query = "Warszawa"
        let initial = viewModel.searchRequest

        viewModel.retry()

        #expect(viewModel.searchRequest != initial)
        #expect(viewModel.searchRequest.attempt == 1)
        #expect(viewModel.searchRequest.isRetry)
        #expect(!initial.isRetry)
    }

    @Test func changingQueryResetsRetryAttempt() {
        let viewModel = makeViewModel()
        viewModel.query = "Warszawa"
        viewModel.retry()

        viewModel.query = "Warszawa"
        #expect(viewModel.searchRequest.attempt == 1)

        viewModel.query = "Kraków"
        #expect(viewModel.searchRequest == .init(query: "Kraków", attempt: 0))
    }

    @Test func selectingLocationAddsItToHistory() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.krakow])
        let viewModel = makeViewModel(store: store)

        viewModel.select(Fixtures.warsaw)
        await viewModel.history.load()

        #expect(viewModel.history.items == [Fixtures.warsaw, Fixtures.krakow])
        #expect(await store.items == [Fixtures.warsaw, Fixtures.krakow])
    }
}
