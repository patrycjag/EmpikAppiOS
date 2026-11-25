import Domain
import Networking

public struct OpenMeteoForecastService: ForecastProviding {
    private let client: any HTTPClient

    public init(client: any HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    public func forecast(for location: Location) async throws -> Forecast {
        let endpoint = OpenMeteoEndpoint.forecast(latitude: location.latitude, longitude: location.longitude)
        do {
            let response = try await client.get(endpoint, as: ForecastResponseDTO.self)
            return try ForecastMapper.forecast(from: response)
        } catch let error as NetworkError {
            throw WeatherServiceError(networkError: error)
        }
    }

    public func dailyForecast(for location: Location, days: Int) async throws -> [DailyForecast] {
        let endpoint = OpenMeteoEndpoint.dailyForecast(
            latitude: location.latitude,
            longitude: location.longitude,
            days: days
        )
        do {
            let response = try await client.get(endpoint, as: ForecastResponseDTO.self)
            return try ForecastMapper.dailyForecasts(from: response)
        } catch let error as NetworkError {
            throw WeatherServiceError(networkError: error)
        }
    }
}
