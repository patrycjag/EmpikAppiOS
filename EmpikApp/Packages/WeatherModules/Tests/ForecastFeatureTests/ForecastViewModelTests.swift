import Domain
import ForecastFeature
import TestSupport
import Testing

@MainActor
struct ForecastViewModelTests {
    private func makeViewModel(_ provider: ForecastProviderStub) -> ForecastViewModel {
        ForecastViewModel(location: Fixtures.warsaw, forecastProvider: provider)
    }

    @Test func startsLoading() {
        let viewModel = makeViewModel(ForecastProviderStub())

        #expect(viewModel.location == Fixtures.warsaw)
        #expect(viewModel.state == .loading)
        #expect(viewModel.dailyState == .loading)
        #expect(viewModel.refreshError == nil)
    }

    @Test func loadsCurrentAndDailyForecast() async {
        let provider = ForecastProviderStub()
        let viewModel = makeViewModel(provider)

        await viewModel.loadIfNeeded()

        #expect(viewModel.state == .loaded(Fixtures.forecast()))
        #expect(viewModel.dailyState == .loaded(Fixtures.dailyForecasts()))
        #expect(provider.forecastRequests.value == [Fixtures.warsaw])
        #expect(provider.dailyRequests.value == [ForecastViewModel.dailyForecastDays])
    }

    @Test func loadsOnlyOnce() async {
        let provider = ForecastProviderStub()
        let viewModel = makeViewModel(provider)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(provider.forecastRequests.value.count == 1)
        #expect(provider.dailyRequests.value.count == 1)
    }

    @Test func showsForecastFailure() async {
        let viewModel = makeViewModel(ForecastProviderStub(forecast: .failure(WeatherServiceError.offline)))

        await viewModel.loadIfNeeded()

        #expect(viewModel.state == .failure(.offline))
        #expect(viewModel.dailyState == .loaded(Fixtures.dailyForecasts()))
    }

    @Test func showsDailyFailureIndependently() async {
        let viewModel = makeViewModel(ForecastProviderStub(daily: .failure(TestError("Brak danych"))))

        await viewModel.loadIfNeeded()

        #expect(viewModel.state == .loaded(Fixtures.forecast()))
        #expect(viewModel.dailyState == .failure(.general(message: "Brak danych")))
    }

    @Test func ignoresCancellation() async {
        let viewModel = makeViewModel(
            ForecastProviderStub(forecast: .failure(CancellationError()), daily: .failure(CancellationError()))
        )

        await viewModel.loadIfNeeded()

        #expect(viewModel.state == .loading)
        #expect(viewModel.dailyState == .loading)
    }

    @Test func refreshReplacesLoadedForecast() async {
        let provider = ForecastProviderStub()
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()

        provider.forecastResult.setValue(.success(Fixtures.forecast(hours: 3)))
        provider.dailyResult.setValue(.success(Fixtures.dailyForecasts(count: 3)))
        await viewModel.refresh()

        #expect(viewModel.state == .loaded(Fixtures.forecast(hours: 3)))
        #expect(viewModel.dailyState == .loaded(Fixtures.dailyForecasts(count: 3)))
        #expect(viewModel.refreshError == nil)
    }

    @Test func failedRefreshKeepsLoadedDataAndReportsError() async {
        let provider = ForecastProviderStub()
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()

        provider.forecastResult.setValue(.failure(WeatherServiceError.offline))
        provider.dailyResult.setValue(.failure(WeatherServiceError.offline))
        await viewModel.refresh()

        #expect(viewModel.state == .loaded(Fixtures.forecast()))
        #expect(viewModel.dailyState == .loaded(Fixtures.dailyForecasts()))
        #expect(viewModel.refreshError == .offline)
    }

    @Test func successfulRefreshClearsRefreshError() async {
        let provider = ForecastProviderStub()
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()
        provider.forecastResult.setValue(.failure(WeatherServiceError.offline))
        await viewModel.refresh()

        provider.forecastResult.setValue(.success(Fixtures.forecast()))
        await viewModel.refresh()

        #expect(viewModel.refreshError == nil)
    }

    @Test func failedRefreshWithoutDataShowsFailure() async {
        let provider = ForecastProviderStub(
            forecast: .failure(WeatherServiceError.offline),
            daily: .failure(WeatherServiceError.offline)
        )
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()

        provider.forecastResult.setValue(.failure(TestError("Serwer niedostępny")))
        provider.dailyResult.setValue(.failure(TestError("Serwer niedostępny")))
        await viewModel.refresh()

        #expect(viewModel.state == .failure(.general(message: "Serwer niedostępny")))
        #expect(viewModel.dailyState == .failure(.general(message: "Serwer niedostępny")))
        #expect(viewModel.refreshError == nil)
    }

    @Test func reloadStartsOverAfterFailure() async {
        let provider = ForecastProviderStub(forecast: .failure(WeatherServiceError.offline))
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()
        #expect(viewModel.state == .failure(.offline))

        provider.forecastResult.setValue(.success(Fixtures.forecast()))
        viewModel.reload()

        let loaded = await waitUntil { viewModel.state == .loaded(Fixtures.forecast()) }
        #expect(loaded)
        #expect(provider.forecastRequests.value.count == 2)
    }

    @Test func reloadClearsRefreshError() async {
        let provider = ForecastProviderStub()
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()
        provider.forecastResult.setValue(.failure(WeatherServiceError.offline))
        await viewModel.refresh()
        #expect(viewModel.refreshError == .offline)

        provider.forecastResult.setValue(.success(Fixtures.forecast()))
        viewModel.reload()

        let cleared = await waitUntil { viewModel.refreshError == nil && viewModel.state != .loading }
        #expect(cleared)
        #expect(viewModel.state == .loaded(Fixtures.forecast()))
    }

    @Test func retryDailyForecastReloadsOnlyDailyForecast() async {
        let provider = ForecastProviderStub(daily: .failure(WeatherServiceError.offline))
        let viewModel = makeViewModel(provider)
        await viewModel.loadIfNeeded()
        #expect(viewModel.dailyState == .failure(.offline))

        provider.dailyResult.setValue(.success(Fixtures.dailyForecasts()))
        viewModel.retryDailyForecast()
        #expect(viewModel.dailyState == .loading)

        let loaded = await waitUntil { viewModel.dailyState == .loaded(Fixtures.dailyForecasts()) }
        #expect(loaded)
        #expect(provider.forecastRequests.value.count == 1)
        #expect(provider.dailyRequests.value.count == 2)
    }
}
