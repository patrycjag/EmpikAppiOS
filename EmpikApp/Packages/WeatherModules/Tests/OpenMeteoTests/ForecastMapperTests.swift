import Domain
import Foundation
@testable import OpenMeteo
import Testing

struct ForecastMapperTests {
    private func response(
        timezone: String? = "Europe/Warsaw",
        utcOffsetSeconds: Int? = 3_600,
        current: CurrentDTO? = nil,
        hourly: HourlyDTO? = nil,
        daily: DailyDTO? = nil
    ) -> ForecastResponseDTO {
        ForecastResponseDTO(
            timezone: timezone,
            utcOffsetSeconds: utcOffsetSeconds,
            current: current,
            hourly: hourly,
            daily: daily
        )
    }

    @Test func throwsWhenDailyForecastIsMissing() {
        #expect(throws: WeatherServiceError.general(message: "Odpowiedź nie zawiera prognozy dziennej.")) {
            try ForecastMapper.dailyForecasts(from: response())
        }
    }

    @Test func usesTimeZoneIdentifier() {
        #expect(ForecastMapper.timeZone(from: response(timezone: "Asia/Tokyo")) == TimeZone(identifier: "Asia/Tokyo"))
    }

    @Test func fallsBackToUTCOffset() {
        let timeZone = ForecastMapper.timeZone(from: response(timezone: "Mars/Olympus_Mons", utcOffsetSeconds: 7_200))
        #expect(timeZone.secondsFromGMT() == 7_200)
    }

    @Test func fallsBackToCurrentTimeZone() {
        #expect(ForecastMapper.timeZone(from: response(timezone: nil, utcOffsetSeconds: nil)) == .current)
        #expect(ForecastMapper.timeZone(from: response(timezone: "Invalid/Zone", utcOffsetSeconds: nil)) == .current)
    }
}
