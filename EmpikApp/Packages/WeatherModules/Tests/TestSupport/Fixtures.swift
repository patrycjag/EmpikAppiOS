import Domain
import Foundation

public enum Fixtures {
    public static let warsaw = Location(
        id: 756_135,
        name: "Warszawa",
        latitude: 52.22977,
        longitude: 21.01178,
        region: "Mazowieckie",
        country: "Polska",
        countryCode: "PL"
    )

    public static let krakow = Location(
        id: 3_094_802,
        name: "Kraków",
        latitude: 50.06143,
        longitude: 19.93658,
        region: "Małopolskie",
        country: "Polska",
        countryCode: "PL"
    )

    public static let gdansk = Location(
        id: 3_099_434,
        name: "Gdańsk",
        latitude: 54.35205,
        longitude: 18.64637
    )

    public static let referenceDate = Date(iso8601: "2025-11-26T11:00:00+01:00")
    public static let warsawTimeZone = TimeZone(identifier: "Europe/Warsaw")!

    public static func forecast(hours: Int = 24) -> Forecast {
        let conditions = WeatherCondition.allCases
        return Forecast(
            current: CurrentWeather(
                date: referenceDate,
                temperature: 3.4,
                apparentTemperature: -1.2,
                cloudCover: 75,
                precipitationProbability: 20,
                condition: .overcast,
                isDay: true
            ),
            hourly: (0..<hours).map { index in
                HourlyForecast(
                    date: referenceDate.addingTimeInterval(TimeInterval(index) * 3_600),
                    temperature: 3.4 + Double(index % 5),
                    precipitationProbability: index.isMultiple(of: 3) ? nil : (index * 10) % 100,
                    condition: conditions[index % conditions.count],
                    isDay: index < 12
                )
            },
            timeZone: warsawTimeZone
        )
    }

    public static func dailyForecasts(count: Int = 7) -> [DailyForecast] {
        let conditions = WeatherCondition.allCases
        return (0..<count).map { index in
            DailyForecast(
                date: referenceDate.addingTimeInterval(TimeInterval(index) * 86_400),
                minTemperature: -2 + Double(index),
                maxTemperature: 4 + Double(index),
                precipitationProbability: index == 0 ? nil : 15 * index,
                condition: conditions[index % conditions.count]
            )
        }
    }
}
