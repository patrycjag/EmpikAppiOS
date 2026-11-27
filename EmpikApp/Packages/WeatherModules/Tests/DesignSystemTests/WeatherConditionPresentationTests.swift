import DesignSystem
import Domain
import SwiftUI
import Testing
import UIKit

struct WeatherConditionPresentationTests {
    @Test func everyConditionHasAUniqueDisplayName() {
        let names = WeatherCondition.allCases.map(\.displayName)
        #expect(names.allSatisfy { !$0.isEmpty })
        #expect(Set(names).count == names.count)
    }

    @Test(arguments: WeatherCondition.allCases, [true, false])
    func symbolNameIsAValidSFSymbol(condition: WeatherCondition, isDay: Bool) {
        let name = condition.symbolName(isDay: isDay)
        #expect(UIImage(systemName: name) != nil, "Missing SF Symbol \(name)")
    }

    @Test func clearSkyUsesDifferentSymbolsForDayAndNight() {
        #expect(WeatherCondition.clearSky.symbolName(isDay: true) == "sun.max.fill")
        #expect(WeatherCondition.clearSky.symbolName(isDay: false) == "moon.stars.fill")
        #expect(WeatherCondition.rainShowers.symbolName(isDay: false) == "cloud.moon.rain.fill")
    }

    @Test func cloudyConditionsUseTheSameSymbolDayAndNight() {
        #expect(WeatherCondition.overcast.symbolName(isDay: true) == WeatherCondition.overcast.symbolName(isDay: false))
        #expect(WeatherCondition.snow.symbolName() == WeatherCondition.snowShowers.symbolName())
    }

    @Test func tintReflectsConditionAndTimeOfDay() {
        #expect(WeatherCondition.clearSky.tint(isDay: true) == .orange)
        #expect(WeatherCondition.clearSky.tint(isDay: false) == .indigo)
        #expect(WeatherCondition.fog.tint() == .gray)
        #expect(WeatherCondition.rain.tint() == .blue)
        #expect(WeatherCondition.snowGrains.tint() == .cyan)
        #expect(WeatherCondition.thunderstormWithHail.tint() == .purple)
        #expect(WeatherCondition.unknown.tint() == .secondary)
    }
}
