import Domain
import Foundation
import Networking
import OpenMeteo
import TestSupport
import Testing

struct OpenMeteoForecastServiceTests {
    // Unix timestamps, as Open-Meteo sends them: current 2025-11-26 11:15, hourly 11:00 and 12:00 (Europe/Warsaw).
    private static let forecastJSON = """
    {
      "timezone": "Europe/Warsaw",
      "utc_offset_seconds": 3600,
      "current": {
        "time": 1764152100,
        "temperature_2m": 3.4,
        "apparent_temperature": -1.2,
        "cloud_cover": 75,
        "weather_code": 61,
        "is_day": 1
      },
      "hourly": {
        "time": [1764151200, 1764154800],
        "temperature_2m": [3.1, 3.8],
        "precipitation_probability": [40, 55],
        "weather_code": [61, 63],
        "is_day": [1, 1]
      }
    }
    """

    // Unix timestamps, as Open-Meteo sends them: midnight on 2025-11-26 and 2025-11-27 (Europe/Warsaw).
    private static let dailyJSON = """
    {
      "timezone": "Europe/Warsaw",
      "daily": {
        "time": [1764111600, 1764198000],
        "temperature_2m_max": [4.1, 6.3],
        "temperature_2m_min": [-0.5, 1.2],
        "precipitation_probability_max": [35, null],
        "weather_code": [3, 0]
      }
    }
    """

    @Test func fetchesAndMapsForecast() async throws {
        let client = HTTPClientStub(json: Self.forecastJSON)
        let service = OpenMeteoForecastService(client: client)

        let forecast = try await service.forecast(for: Fixtures.warsaw)

        #expect(forecast.current.temperature == 3.4)
        #expect(forecast.current.condition == .rain)
        #expect(forecast.current.precipitationProbability == 40)
        #expect(forecast.hourly.map(\.temperature) == [3.1, 3.8])
        #expect(forecast.timeZone == TimeZone(identifier: "Europe/Warsaw"))

        let request = try #require(client.lastRequest)
        #expect(request.url?.host() == "api.open-meteo.com")
        #expect(request.url?.path() == "/v1/forecast")
        #expect(request.queryParameters["latitude"] == "52.22977")
        #expect(request.queryParameters["longitude"] == "21.01178")
    }

    @Test func fetchesAndMapsDailyForecast() async throws {
        let client = HTTPClientStub(json: Self.dailyJSON)
        let service = OpenMeteoForecastService(client: client)

        let days = try await service.dailyForecast(for: Fixtures.krakow, days: 7)

        #expect(days == [
            DailyForecast(
                date: Date(iso8601: "2025-11-26T00:00:00+01:00"),
                minTemperature: -0.5,
                maxTemperature: 4.1,
                precipitationProbability: 35,
                condition: .overcast
            ),
            DailyForecast(
                date: Date(iso8601: "2025-11-27T00:00:00+01:00"),
                minTemperature: 1.2,
                maxTemperature: 6.3,
                precipitationProbability: nil,
                condition: .clearSky
            ),
        ])
        #expect(client.lastRequest?.queryParameters["forecast_days"] == "7")
        #expect(client.lastRequest?.queryParameters["latitude"] == "50.06143")
    }

    @Test func mapsOfflineError() async {
        let service = OpenMeteoForecastService(client: HTTPClientStub(response: .failure(NetworkError.offline)))

        await #expect(throws: WeatherServiceError.offline) {
            try await service.forecast(for: Fixtures.warsaw)
        }
        await #expect(throws: WeatherServiceError.offline) {
            try await service.dailyForecast(for: Fixtures.warsaw, days: 7)
        }
    }

    @Test func mapsServerError() async {
        let service = OpenMeteoForecastService(client: HTTPClientStub(statusCode: 500, json: "{}"))

        await #expect(throws: WeatherServiceError.general(message: "Serwer zwrócił błąd (kod 500).")) {
            try await service.forecast(for: Fixtures.warsaw)
        }
    }

    @Test func throwsWhenResponseHasNoForecastData() async {
        let service = OpenMeteoForecastService(client: HTTPClientStub(json: #"{"timezone":"UTC"}"#))

        await #expect(throws: WeatherServiceError.general(message: "Odpowiedź nie zawiera aktualnej prognozy.")) {
            try await service.forecast(for: Fixtures.warsaw)
        }
        await #expect(throws: WeatherServiceError.general(message: "Odpowiedź nie zawiera prognozy dziennej.")) {
            try await service.dailyForecast(for: Fixtures.warsaw, days: 7)
        }
    }

    @Test func passesCancellationThrough() async {
        let service = OpenMeteoForecastService(client: HTTPClientStub(response: .failure(CancellationError())))

        await #expect(throws: CancellationError.self) {
            try await service.forecast(for: Fixtures.warsaw)
        }
    }
}
