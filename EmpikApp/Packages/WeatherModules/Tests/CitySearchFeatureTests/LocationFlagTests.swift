@testable import CitySearchFeature
import Domain
import Testing

struct LocationFlagTests {
    private func location(countryCode: String?) -> Location {
        Location(id: 1, name: "Test", latitude: 0, longitude: 0, countryCode: countryCode)
    }

    @Test(arguments: [("PL", "🇵🇱"), ("pl", "🇵🇱"), ("DE", "🇩🇪"), ("us", "🇺🇸")])
    func buildsFlagFromCountryCode(code: String, flag: String) {
        #expect(location(countryCode: code).flagEmoji == flag)
    }

    @Test(arguments: [nil, "", "P", "POL", "P1", "ŁĄ", "--"] as [String?])
    func returnsNilForInvalidCountryCodes(code: String?) {
        #expect(location(countryCode: code).flagEmoji == nil)
    }
}
