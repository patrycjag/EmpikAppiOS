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

    public let location: Location
    public private(set) var state: State = .loading

    @ObservationIgnored private var hasLoaded = false
    @ObservationIgnored private var reloadTask: Task<Void, Never>?
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
        reloadTask = Task { await load() }
    }

    private func load() async {
        state = .loading
        await fetchForecast()
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
}
