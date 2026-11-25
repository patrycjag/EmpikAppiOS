import Foundation
import Networking

enum OpenMeteoEndpoint {
    static let geocodingBaseURL = URL(string: "https://geocoding-api.open-meteo.com")!

    static func search(name: String, language: String, count: Int) -> Endpoint {
        Endpoint(
            baseURL: geocodingBaseURL,
            path: "v1/search",
            queryItems: [
                .init("name", name),
                .init("count", String(count)),
                .init("language", language),
                .init("format", "json"),
            ]
        )
    }
}
