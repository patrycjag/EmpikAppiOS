import Domain
import Foundation

enum ForecastMapper {
    static let hourlyLimit = 24

    static func forecast(from dto: ForecastResponseDTO) throws -> Forecast {
        guard let current = dto.current, let hourly = dto.hourly else {
            throw WeatherServiceError.general(message: "Odpowiedź nie zawiera aktualnej prognozy.")
        }

        let currentDate = Date(timeIntervalSince1970: current.time)
        let hours = hourlyForecasts(from: hourly)

        let currentHourIndex = hours.lastIndex { $0.date <= currentDate }
        let upcoming = currentHourIndex.map { Array(hours[$0...]) } ?? hours

        let currentWeather = CurrentWeather(
            date: currentDate,
            temperature: current.temperature2m,
            apparentTemperature: current.apparentTemperature ?? current.temperature2m,
            cloudCover: percentage(current.cloudCover) ?? 0,
            precipitationProbability: currentHourIndex.flatMap { hours[$0].precipitationProbability },
            condition: WeatherCondition(wmoCode: current.weatherCode),
            isDay: (current.isDay ?? 1) == 1
        )

        return Forecast(
            current: currentWeather,
            hourly: Array(upcoming.prefix(hourlyLimit)),
            timeZone: timeZone(from: dto)
        )
    }

    static func dailyForecasts(from dto: ForecastResponseDTO) throws -> [DailyForecast] {
        guard let daily = dto.daily else {
            throw WeatherServiceError.general(message: "Odpowiedź nie zawiera prognozy dziennej.")
        }

        return daily.time.indices.compactMap { index in
            guard
                let maxTemperature = value(daily.temperature2mMax, at: index),
                let minTemperature = value(daily.temperature2mMin, at: index)
            else { return nil }

            return DailyForecast(
                date: Date(timeIntervalSince1970: daily.time[index]),
                minTemperature: minTemperature,
                maxTemperature: maxTemperature,
                precipitationProbability: percentage(value(daily.precipitationProbabilityMax, at: index)),
                condition: WeatherCondition(wmoCode: value(daily.weatherCode, at: index))
            )
        }
    }

    static func timeZone(from dto: ForecastResponseDTO) -> TimeZone {
        if let identifier = dto.timezone, let timeZone = TimeZone(identifier: identifier) {
            return timeZone
        }
        if let offset = dto.utcOffsetSeconds, let timeZone = TimeZone(secondsFromGMT: offset) {
            return timeZone
        }
        return .current
    }

    private static func hourlyForecasts(from hourly: HourlyDTO) -> [HourlyForecast] {
        hourly.time.indices.compactMap { index in
            guard let temperature = value(hourly.temperature2m, at: index) else { return nil }

            return HourlyForecast(
                date: Date(timeIntervalSince1970: hourly.time[index]),
                temperature: temperature,
                precipitationProbability: percentage(value(hourly.precipitationProbability, at: index)),
                condition: WeatherCondition(wmoCode: value(hourly.weatherCode, at: index)),
                isDay: (value(hourly.isDay, at: index) ?? 1) == 1
            )
        }
    }

    private static func value<T>(_ series: [T?]?, at index: Int) -> T? {
        guard let series, series.indices.contains(index) else { return nil }
        return series[index]
    }

    private static func percentage(_ value: Double?) -> Int? {
        guard let value else { return nil }
        return min(max(Int(value.rounded()), 0), 100)
    }
}
