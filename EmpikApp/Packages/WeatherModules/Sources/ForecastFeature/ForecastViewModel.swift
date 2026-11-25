import Domain
import Observation

@MainActor
@Observable
public final class ForecastViewModel {
    public enum State: Equatable {
        case loading
        case loaded(Forecast)
        case failure(WeatherServiceError)
    }

    public enum DailyState: Equatable {
        case loading
        case loaded([DailyForecast])
        case failure(WeatherServiceError)
    }

    public static let dailyForecastDays = 7

    public let location: Location
    public private(set) var state: State = .loading
    public private(set) var dailyState: DailyState = .loading
    public private(set) var refreshError: WeatherServiceError?

    @ObservationIgnored private var hasLoaded = false
    @ObservationIgnored private var reloadTask: Task<Void, Never>?
    @ObservationIgnored private var dailyRetryTask: Task<Void, Never>?
    private let forecastProvider: any ForecastProviding

    public init(location: Location, forecastProvider: any ForecastProviding) {
        self.location = location
        self.forecastProvider = forecastProvider
    }

    public func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await load()
    }

    public func reload() {
        reloadTask?.cancel()
        dailyRetryTask?.cancel()
        reloadTask = Task { await load() }
    }

    public func refresh() async {
        await fetch(isRefresh: true)
    }

    public func retryDailyForecast() {
        dailyRetryTask?.cancel()
        dailyState = .loading
        dailyRetryTask = Task { await fetchDailyForecast(isRefresh: false) }
    }

    private func load() async {
        state = .loading
        dailyState = .loading
        refreshError = nil
        await fetch(isRefresh: false)
    }

    private func fetch(isRefresh: Bool) async {
        async let forecast: Void = fetchForecast(isRefresh: isRefresh)
        async let daily: Void = fetchDailyForecast(isRefresh: isRefresh)
        _ = await (forecast, daily)
    }

    private func fetchForecast(isRefresh: Bool) async {
        do {
            let forecast = try await forecastProvider.forecast(for: location)
            guard !Task.isCancelled else { return }
            state = .loaded(forecast)
            refreshError = nil
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            let error = WeatherServiceError(error)
            if isRefresh, case .loaded = state {
                refreshError = error
            } else {
                state = .failure(error)
            }
        }
    }

    private func fetchDailyForecast(isRefresh: Bool) async {
        do {
            let days = try await forecastProvider.dailyForecast(for: location, days: Self.dailyForecastDays)
            guard !Task.isCancelled else { return }
            dailyState = .loaded(days)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            if isRefresh, case .loaded = dailyState {
                return
            }
            dailyState = .failure(WeatherServiceError(error))
        }
    }
}
