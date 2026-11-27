import DesignSystem
import Foundation
import TestSupport
import Testing

struct WeatherFormatTests {
    private let date = Date(iso8601: "2025-11-26T10:00:00Z")

    @Test func temperatureIsRoundedToWholeDegrees() {
        #expect(WeatherFormat.temperature(21.6) == WeatherFormat.temperature(22))
        #expect(WeatherFormat.temperature(21.4) == WeatherFormat.temperature(21))
        #expect(WeatherFormat.temperature(21) != WeatherFormat.temperature(22))
        #expect(WeatherFormat.temperature(22).contains("°"))
    }

    @Test func temperatureNeverShowsNegativeZero() {
        #expect(WeatherFormat.temperature(-0.4) == WeatherFormat.temperature(0))
    }

    @Test func negativeTemperaturesDifferFromPositive() {
        #expect(WeatherFormat.temperature(-5) != WeatherFormat.temperature(5))
    }

    @Test func percentFormatsWholeNumbers() {
        let text = WeatherFormat.percent(42)
        #expect(text.contains("42"))
        #expect(text.contains("%"))
    }

    @Test func hourUsesGivenTimeZone() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))

        #expect(WeatherFormat.hour(date, timeZone: utc).contains("10"))
        #expect(WeatherFormat.hour(date, timeZone: utc) != WeatherFormat.hour(date, timeZone: tokyo))
    }

    @Test func weekdayIsCapitalizedAndUsesGivenTimeZone() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let kiritimati = try #require(TimeZone(identifier: "Pacific/Kiritimati"))

        let weekday = WeatherFormat.weekday(date, timeZone: utc)

        #expect(weekday.first?.isUppercase == true)
        #expect(weekday != WeatherFormat.weekday(date, timeZone: kiritimati))
    }
}
