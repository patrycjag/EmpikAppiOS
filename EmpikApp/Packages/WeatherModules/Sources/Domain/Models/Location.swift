import Foundation

public struct Location: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let region: String?
    public let country: String?
    public let countryCode: String?

    public init(
        id: Int,
        name: String,
        latitude: Double,
        longitude: Double,
        region: String? = nil,
        country: String? = nil,
        countryCode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.region = region
        self.country = country
        self.countryCode = countryCode
    }
}

public extension Location {
    var detailsDescription: String {
        [region, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
