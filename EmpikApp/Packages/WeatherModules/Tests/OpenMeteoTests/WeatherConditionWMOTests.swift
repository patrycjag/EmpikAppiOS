import Domain
@testable import OpenMeteo
import Testing

struct WeatherConditionWMOTests {
    static let mapping: [(Int, WeatherCondition)] = [
        (0, .clearSky),
        (1, .mainlyClear),
        (2, .partlyCloudy),
        (3, .overcast),
        (45, .fog), (48, .fog),
        (51, .drizzle), (53, .drizzle), (55, .drizzle),
        (56, .freezingDrizzle), (57, .freezingDrizzle),
        (61, .rain), (63, .rain), (65, .rain),
        (66, .freezingRain), (67, .freezingRain),
        (71, .snow), (73, .snow), (75, .snow),
        (77, .snowGrains),
        (80, .rainShowers), (81, .rainShowers), (82, .rainShowers),
        (85, .snowShowers), (86, .snowShowers),
        (95, .thunderstorm),
        (96, .thunderstormWithHail), (99, .thunderstormWithHail),
    ]

    @Test(arguments: WeatherConditionWMOTests.mapping)
    func mapsWMOCode(code: Int, expected: WeatherCondition) {
        #expect(WeatherCondition(wmoCode: code) == expected)
    }

    @Test(arguments: [-1, 4, 50, 100])
    func mapsUnknownCodesToUnknown(code: Int) {
        #expect(WeatherCondition(wmoCode: code) == .unknown)
    }

    @Test func mapsMissingCodeToUnknown() {
        #expect(WeatherCondition(wmoCode: nil) == .unknown)
    }
}
