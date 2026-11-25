import Foundation

public struct Forecast: Equatable, Sendable {
    public let current: CurrentWeather
    public let hourly: [HourlyForecast]
    public let timeZone: TimeZone

    public init(current: CurrentWeather, hourly: [HourlyForecast], timeZone: TimeZone) {
        self.current = current
        self.hourly = hourly
        self.timeZone = timeZone
    }
}

public struct CurrentWeather: Equatable, Sendable {
    public let date: Date
    public let temperature: Double
    public let apparentTemperature: Double
    public let cloudCover: Int
    public let precipitationProbability: Int?
    public let condition: WeatherCondition
    public let isDay: Bool

    public init(
        date: Date,
        temperature: Double,
        apparentTemperature: Double,
        cloudCover: Int,
        precipitationProbability: Int?,
        condition: WeatherCondition,
        isDay: Bool
    ) {
        self.date = date
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.cloudCover = cloudCover
        self.precipitationProbability = precipitationProbability
        self.condition = condition
        self.isDay = isDay
    }
}

public struct HourlyForecast: Identifiable, Equatable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let temperature: Double
    public let precipitationProbability: Int?
    public let condition: WeatherCondition
    public let isDay: Bool

    public init(
        date: Date,
        temperature: Double,
        precipitationProbability: Int?,
        condition: WeatherCondition,
        isDay: Bool
    ) {
        self.date = date
        self.temperature = temperature
        self.precipitationProbability = precipitationProbability
        self.condition = condition
        self.isDay = isDay
    }
}

public struct DailyForecast: Identifiable, Equatable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let minTemperature: Double
    public let maxTemperature: Double
    public let precipitationProbability: Int?
    public let condition: WeatherCondition

    public init(
        date: Date,
        minTemperature: Double,
        maxTemperature: Double,
        precipitationProbability: Int?,
        condition: WeatherCondition
    ) {
        self.date = date
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.precipitationProbability = precipitationProbability
        self.condition = condition
    }
}
