import Domain
import Foundation
import Networking
@testable import OpenMeteo
import TestSupport
import Testing

struct OpenMeteoLocationServiceTests {
    private static let searchJSON = """
    {
      "results": [
        {
          "id": 756135,
          "name": "Warszawa",
          "latitude": 52.22977,
          "longitude": 21.01178,
          "country": "Polska",
          "country_code": "PL",
          "admin1": "Mazowieckie",
          "population": 1702139
        },
        {
          "id": 3081368,
          "name": "Wrocław",
          "latitude": 51.1,
          "longitude": 17.03333
        }
      ],
      "generationtime_ms": 0.5
    }
    """

    @Test func searchesAndMapsLocations() async throws {
        let client = HTTPClientStub(json: Self.searchJSON)
        let service = OpenMeteoLocationService(client: client, language: "pl", resultsLimit: 5)

        let locations = try await service.searchLocations(named: "Wars")

        #expect(locations == [
            Location(
                id: 756_135,
                name: "Warszawa",
                latitude: 52.22977,
                longitude: 21.01178,
                region: "Mazowieckie",
                country: "Polska",
                countryCode: "PL"
            ),
            Location(id: 3_081_368, name: "Wrocław", latitude: 51.1, longitude: 17.03333),
        ])

        let request = try #require(client.lastRequest)
        #expect(request.url?.host() == "geocoding-api.open-meteo.com")
        #expect(request.url?.path() == "/v1/search")
        #expect(request.queryParameters["name"] == "Wars")
        #expect(request.queryParameters["language"] == "pl")
        #expect(request.queryParameters["count"] == "5")
    }

    @Test func returnsEmptyListWhenThereAreNoResults() async throws {
        let service = OpenMeteoLocationService(client: HTTPClientStub(json: #"{"generationtime_ms":0.3}"#))

        #expect(try await service.searchLocations(named: "Atlantyda").isEmpty)
    }

    @Test func mapsNetworkErrors() async {
        let offline = OpenMeteoLocationService(client: HTTPClientStub(response: .failure(NetworkError.offline)))
        await #expect(throws: WeatherServiceError.offline) {
            try await offline.searchLocations(named: "Warszawa")
        }

        let failing = OpenMeteoLocationService(client: HTTPClientStub(statusCode: 503, json: "{}"))
        await #expect(throws: WeatherServiceError.general(message: "Serwer zwrócił błąd (kod 503).")) {
            try await failing.searchLocations(named: "Warszawa")
        }
    }

    @Test func preferredLanguageIsALanguageCode() {
        let language = OpenMeteoLocationService.preferredLanguage
        #expect(!language.isEmpty)
        #expect(!language.contains("-"))
    }

    @Test func mapsNetworkErrorToWeatherServiceError() {
        #expect(WeatherServiceError(networkError: .offline) == .offline)
        #expect(WeatherServiceError(networkError: .general(message: "Błąd")) == .general(message: "Błąd"))
    }
}
