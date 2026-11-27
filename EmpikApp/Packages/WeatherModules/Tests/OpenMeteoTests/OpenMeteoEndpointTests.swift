import Foundation
import Networking
@testable import OpenMeteo
import Testing

struct OpenMeteoEndpointTests {
    private func parameters(_ endpoint: Endpoint) -> [String: String] {
        Dictionary(uniqueKeysWithValues: endpoint.queryItems.map { ($0.name, $0.value) })
    }

    @Test func searchEndpoint() {
        let endpoint = OpenMeteoEndpoint.search(name: "Warszawa", language: "pl", count: 20)

        #expect(endpoint.baseURL == URL(string: "https://geocoding-api.open-meteo.com"))
        #expect(endpoint.path == "v1/search")
        #expect(endpoint.queryItems == [
            .init("name", "Warszawa"),
            .init("count", "20"),
            .init("language", "pl"),
            .init("format", "json"),
        ])
    }

    @Test func forecastEndpoint() {
        let endpoint = OpenMeteoEndpoint.forecast(latitude: 52.23, longitude: 21.01)

        #expect(endpoint.baseURL == URL(string: "https://api.open-meteo.com"))
        #expect(endpoint.path == "v1/forecast")
        #expect(parameters(endpoint) == [
            "latitude": "52.23",
            "longitude": "21.01",
            "current": "temperature_2m,apparent_temperature,cloud_cover,weather_code,is_day",
            "hourly": "temperature_2m,precipitation_probability,weather_code,is_day",
            "forecast_days": "2",
            "timezone": "auto",
            "timeformat": "unixtime",
        ])
    }

    @Test func dailyForecastEndpoint() {
        let endpoint = OpenMeteoEndpoint.dailyForecast(latitude: 50.06, longitude: 19.94, days: 7)

        #expect(endpoint.baseURL == URL(string: "https://api.open-meteo.com"))
        #expect(endpoint.path == "v1/forecast")
        #expect(parameters(endpoint) == [
            "latitude": "50.06",
            "longitude": "19.94",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max",
            "forecast_days": "7",
            "timezone": "auto",
            "timeformat": "unixtime",
        ])
    }
}
