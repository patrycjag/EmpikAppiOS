import DesignSystem
import Domain
import SwiftUI

struct CurrentConditionsCard: View {
    let location: Location
    let current: CurrentWeather

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 56
    @ScaledMetric(relativeTo: .largeTitle) private var temperatureSize: CGFloat = 64

    init(location: Location, current: CurrentWeather) {
        self.location = location
        self.current = current
    }

    private var temperature: String {
        WeatherFormat.temperature(current.temperature)
    }

    private var apparentTemperature: String {
        WeatherFormat.temperature(current.apparentTemperature)
    }

    private var metricsLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                if !location.detailsDescription.isEmpty {
                    Text(location.detailsDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                WeatherSymbol(condition: current.condition, isDay: current.isDay)
                    .font(.system(size: symbolSize))
                    .padding(.vertical, 4)

                Text(temperature)
                    .font(.system(size: temperatureSize, weight: .thin, design: .rounded))
                    .contentTransition(.numericText())

                Text(current.condition.displayName)
                    .font(.title3.weight(.medium))

                Text("Odczuwalna \(apparentTemperature)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenDescription)

            metricsLayout {
                MetricTile(
                    title: "Zachmurzenie",
                    value: WeatherFormat.percent(current.cloudCover),
                    systemImage: "cloud"
                )
                MetricTile(
                    title: "Szansa opadów",
                    value: current.precipitationProbability.map(WeatherFormat.percent),
                    systemImage: "umbrella"
                )
            }
        }
        .cardStyle()
    }

    private var spokenDescription: String {
        [
            location.detailsDescription,
            "Teraz \(temperature)",
            current.condition.displayName,
            "odczuwalna \(apparentTemperature)",
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }
}

private struct MetricTile: View {
    let title: String
    let value: String?
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value ?? "–")
                .font(.title2.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.groupedBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value ?? "Brak danych")
    }
}
