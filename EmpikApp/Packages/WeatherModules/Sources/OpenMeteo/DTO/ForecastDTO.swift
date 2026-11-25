import Foundation

struct ForecastResponseDTO: Decodable, Sendable {
    let timezone: String?
    let utcOffsetSeconds: Int?
    let current: CurrentDTO?
    let hourly: HourlyDTO?

    enum CodingKeys: String, CodingKey {
        case timezone, current, hourly
        case utcOffsetSeconds = "utc_offset_seconds"
    }
}

struct CurrentDTO: Decodable, Sendable {
    let time: TimeInterval
    let temperature2m: Double
    let apparentTemperature: Double?
    let cloudCover: Double?
    let weatherCode: Int?
    let isDay: Int?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case cloudCover = "cloud_cover"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

struct HourlyDTO: Decodable, Sendable {
    let time: [TimeInterval]
    let temperature2m: [Double?]
    let precipitationProbability: [Double?]?
    let weatherCode: [Int?]?
    let isDay: [Int?]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}
