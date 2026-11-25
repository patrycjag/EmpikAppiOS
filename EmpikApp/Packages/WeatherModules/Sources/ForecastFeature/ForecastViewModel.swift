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

    public func retryDailyForecast() {
        dailyRetryTask?.cancel()
        dailyState = .loading
        dailyRetryTask = Task { await fetchDailyForecast() }
    }

    private func load() async {
        state = .loading
        dailyState = .loading
        await fetch()
    }

    private func fetch() async {
        async let forecast: Void = fetchForecast()
        async let daily: Void = fetchDailyForecast()
        _ = await (forecast, daily)
    }

    private func fetchForecast() async {
        do {
            let forecast = try await forecastProvider.forecast(for: location)
            guard !Task.isCancelled else { return }
            state = .loaded(forecast)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            state = .failure(WeatherServiceError(error))
        }
    }

    private func fetchDailyForecast() async {
        do {
            let days = try await forecastProvider.dailyForecast(for: location, days: Self.dailyForecastDays)
            guard !Task.isCancelled else { return }
            dailyState = .loaded(days)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            dailyState = .failure(WeatherServiceError(error))
        }
    }
}
