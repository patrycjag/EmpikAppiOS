import Foundation

struct ForecastResponseDTO: Decodable, Sendable {
    let timezone: String?
    let utcOffsetSeconds: Int?
    let current: CurrentDTO?
    let hourly: HourlyDTO?
    let daily: DailyDTO?

    enum CodingKeys: String, CodingKey {
        case timezone, current, hourly, daily
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

struct DailyDTO: Decodable, Sendable {
    let time: [TimeInterval]
    let temperature2mMax: [Double?]
    let temperature2mMin: [Double?]
    let precipitationProbabilityMax: [Double?]?
    let weatherCode: [Int?]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case weatherCode = "weather_code"
    }
}
