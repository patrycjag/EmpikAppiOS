import Foundation
import Networking

enum OpenMeteoEndpoint {
    static let geocodingBaseURL = URL(string: "https://geocoding-api.open-meteo.com")!
    static let forecastBaseURL = URL(string: "https://api.open-meteo.com")!

    static let hourlyForecastDays = 2

    static func search(name: String, language: String, count: Int) -> Endpoint {
        Endpoint(
            baseURL: geocodingBaseURL,
            path: "v1/search",
            queryItems: [
                .init("name", name),
                .init("count", String(count)),
                .init("language", language),
                .init("format", "json"),
            ]
        )
    }

    static func forecast(latitude: Double, longitude: Double) -> Endpoint {
        Endpoint(
            baseURL: forecastBaseURL,
            path: "v1/forecast",
            queryItems: coordinates(latitude: latitude, longitude: longitude) + [
                .init("current", "temperature_2m,apparent_temperature,cloud_cover,weather_code,is_day"),
                .init("hourly", "temperature_2m,precipitation_probability,weather_code,is_day"),
                .init("forecast_days", String(hourlyForecastDays)),
            ] + commonParameters
        )
    }

    static func dailyForecast(latitude: Double, longitude: Double, days: Int) -> Endpoint {
        Endpoint(
            baseURL: forecastBaseURL,
            path: "v1/forecast",
            queryItems: coordinates(latitude: latitude, longitude: longitude) + [
                .init("daily", "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
                .init("forecast_days", String(days)),
            ] + commonParameters
        )
    }

    private static func coordinates(latitude: Double, longitude: Double) -> [Endpoint.QueryItem] {
        [.init("latitude", String(latitude)), .init("longitude", String(longitude))]
    }

    private static let commonParameters: [Endpoint.QueryItem] = [
        .init("timezone", "auto"),
        .init("timeformat", "unixtime"),
    ]
}
