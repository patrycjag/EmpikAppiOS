import Domain
import Foundation
import Networking

public struct OpenMeteoLocationService: LocationSearching {
    private let client: any HTTPClient
    private let language: String
    private let resultsLimit: Int

    public init(
        client: any HTTPClient = URLSessionHTTPClient(),
        language: String = OpenMeteoLocationService.preferredLanguage,
        resultsLimit: Int = 20
    ) {
        self.client = client
        self.language = language
        self.resultsLimit = resultsLimit
    }

    public func searchLocations(named query: String) async throws -> [Location] {
        let endpoint = OpenMeteoEndpoint.search(name: query, language: language, count: resultsLimit)
        do {
            let response = try await client.get(endpoint, as: GeocodingResponseDTO.self)
            return (response.results ?? []).map(Location.init(dto:))
        } catch let error as NetworkError {
            throw WeatherServiceError(networkError: error)
        }
    }

    public static var preferredLanguage: String {
        Locale.preferredLanguages.first
            .flatMap { Locale.Language(identifier: $0).languageCode?.identifier }
            ?? "en"
    }
}
