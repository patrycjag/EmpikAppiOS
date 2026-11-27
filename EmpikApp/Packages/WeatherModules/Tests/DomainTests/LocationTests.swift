import Domain
import Foundation
import Testing

struct LocationTests {
    private func location(region: String?, country: String?) -> Location {
        Location(id: 1, name: "Warszawa", latitude: 52.23, longitude: 21.01, region: region, country: country)
    }

    @Test func detailsDescriptionJoinsRegionAndCountry() {
        #expect(location(region: "Mazowieckie", country: "Polska").detailsDescription == "Mazowieckie, Polska")
    }

    @Test func detailsDescriptionSkipsMissingAndEmptyParts() {
        #expect(location(region: nil, country: "Polska").detailsDescription == "Polska")
        #expect(location(region: "Mazowieckie", country: nil).detailsDescription == "Mazowieckie")
        #expect(location(region: "", country: "Polska").detailsDescription == "Polska")
        #expect(location(region: nil, country: nil).detailsDescription.isEmpty)
        #expect(location(region: "", country: "").detailsDescription.isEmpty)
    }

    @Test func roundTripsThroughCodable() throws {
        let location = Location(
            id: 42,
            name: "Kraków",
            latitude: 50.06,
            longitude: 19.94,
            region: "Małopolskie",
            country: "Polska",
            countryCode: "PL"
        )
        let data = try JSONEncoder().encode(location)
        #expect(try JSONDecoder().decode(Location.self, from: data) == location)
    }

    @Test func decodesWithoutOptionalFields() throws {
        let json = #"{"id":1,"name":"Gdańsk","latitude":54.35,"longitude":18.65}"#
        let location = try JSONDecoder().decode(Location.self, from: Data(json.utf8))
        #expect(location == Location(id: 1, name: "Gdańsk", latitude: 54.35, longitude: 18.65))
        #expect(location.region == nil)
        #expect(location.countryCode == nil)
    }
}
