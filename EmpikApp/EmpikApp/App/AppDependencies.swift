import Domain
import Networking
import OpenMeteo
import Persistence

struct AppDependencies {
    let locationSearch: any LocationSearching
    let forecastProvider: any ForecastProviding
    let historyStore: any SearchHistoryStoring

    static func live() -> AppDependencies {
        let httpClient = URLSessionHTTPClient()
        return AppDependencies(
            locationSearch: OpenMeteoLocationService(client: httpClient),
            forecastProvider: OpenMeteoForecastService(client: httpClient),
            historyStore: FileSearchHistoryStore()
        )
    }
}
