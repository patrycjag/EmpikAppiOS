import Domain
import Foundation
import TestSupport
import Testing

struct ForecastModelTests {
    private let date = Date(iso8601: "2025-11-26T11:00:00+01:00")

    @Test func hourlyForecastIsIdentifiedByDate() {
        let hour = HourlyForecast(date: date, temperature: 4, precipitationProbability: 10, condition: .rain, isDay: true)
        #expect(hour.id == date)
    }

    @Test func dailyForecastIsIdentifiedByDate() {
        let day = DailyForecast(date: date, minTemperature: -1, maxTemperature: 5, precipitationProbability: nil, condition: .snow)
        #expect(day.id == date)
        #expect(day.precipitationProbability == nil)
    }

    @Test func forecastStoresItsParts() {
        let current = CurrentWeather(
            date: date,
            temperature: 3.4,
            apparentTemperature: -1.2,
            cloudCover: 75,
            precipitationProbability: nil,
            condition: .overcast,
            isDay: false
        )
        let hour = HourlyForecast(date: date, temperature: 3.4, precipitationProbability: nil, condition: .overcast, isDay: false)
        let timeZone = TimeZone(identifier: "Europe/Warsaw")!
        let forecast = Forecast(current: current, hourly: [hour], timeZone: timeZone)

        #expect(forecast.current == current)
        #expect(forecast.hourly == [hour])
        #expect(forecast.timeZone == timeZone)
        #expect(current.apparentTemperature == -1.2)
        #expect(current.cloudCover == 75)
        #expect(!current.isDay)
    }

    @Test func weatherConditionRawValuesRoundTrip() {
        for condition in WeatherCondition.allCases {
            #expect(WeatherCondition(rawValue: condition.rawValue) == condition)
        }
    }
}
