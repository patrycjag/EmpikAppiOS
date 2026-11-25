import Domain

struct GeocodingResponseDTO: Decodable, Sendable {
    let results: [GeocodingResultDTO]?
}

struct GeocodingResultDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let countryCode: String?
    let admin1: String?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, country, admin1
        case countryCode = "country_code"
    }
}

extension Location {
    init(dto: GeocodingResultDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            latitude: dto.latitude,
            longitude: dto.longitude,
            region: dto.admin1,
            country: dto.country,
            countryCode: dto.countryCode
        )
    }
}
