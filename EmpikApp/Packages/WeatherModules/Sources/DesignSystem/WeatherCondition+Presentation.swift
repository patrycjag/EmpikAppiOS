import Domain
import SwiftUI

public extension WeatherCondition {
    var displayName: String {
        switch self {
        case .clearSky: "Bezchmurnie"
        case .mainlyClear: "Przeważnie pogodnie"
        case .partlyCloudy: "Częściowe zachmurzenie"
        case .overcast: "Pochmurno"
        case .fog: "Mgła"
        case .drizzle: "Mżawka"
        case .freezingDrizzle: "Marznąca mżawka"
        case .rain: "Deszcz"
        case .freezingRain: "Marznący deszcz"
        case .snow: "Śnieg"
        case .snowGrains: "Śnieg ziarnisty"
        case .rainShowers: "Przelotny deszcz"
        case .snowShowers: "Przelotny śnieg"
        case .thunderstorm: "Burza"
        case .thunderstormWithHail: "Burza z gradem"
        case .unknown: "Brak danych"
        }
    }

    func symbolName(isDay: Bool = true) -> String {
        switch self {
        case .clearSky: isDay ? "sun.max.fill" : "moon.stars.fill"
        case .mainlyClear: isDay ? "sun.min.fill" : "moon.fill"
        case .partlyCloudy: isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case .overcast: "cloud.fill"
        case .fog: "cloud.fog.fill"
        case .drizzle: "cloud.drizzle.fill"
        case .freezingDrizzle, .freezingRain: "cloud.sleet.fill"
        case .rain: "cloud.rain.fill"
        case .snow, .snowShowers: "cloud.snow.fill"
        case .snowGrains: "snowflake"
        case .rainShowers: isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case .thunderstorm: "cloud.bolt.fill"
        case .thunderstormWithHail: "cloud.bolt.rain.fill"
        case .unknown: "questionmark.circle"
        }
    }

    func tint(isDay: Bool = true) -> Color {
        switch self {
        case .clearSky, .mainlyClear, .partlyCloudy: isDay ? .orange : .indigo
        case .overcast, .fog: .gray
        case .drizzle, .freezingDrizzle, .rain, .freezingRain, .rainShowers: .blue
        case .snow, .snowGrains, .snowShowers: .cyan
        case .thunderstorm, .thunderstormWithHail: .purple
        case .unknown: .secondary
        }
    }
}

public struct WeatherSymbol: View {
    private let condition: WeatherCondition
    private let isDay: Bool

    public init(condition: WeatherCondition, isDay: Bool = true) {
        self.condition = condition
        self.isDay = isDay
    }

    public var body: some View {
        Image(systemName: condition.symbolName(isDay: isDay))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(condition.tint(isDay: isDay))
            .accessibilityLabel(condition.displayName)
    }
}
