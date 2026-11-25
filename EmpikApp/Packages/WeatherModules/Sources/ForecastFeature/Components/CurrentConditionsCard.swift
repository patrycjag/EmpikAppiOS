import DesignSystem
import Domain
import SwiftUI

struct CurrentConditionsCard: View {
    let location: Location
    let current: CurrentWeather

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                if !location.detailsDescription.isEmpty {
                    Text(location.detailsDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                WeatherSymbol(condition: current.condition, isDay: current.isDay)
                    .font(.system(size: 56))
                    .padding(.vertical, 4)

                Text(WeatherFormat.temperature(current.temperature))
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .contentTransition(.numericText())

                Text(current.condition.displayName)
                    .font(.title3.weight(.medium))

                Text("Odczuwalna \(WeatherFormat.temperature(current.apparentTemperature))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            HStack(spacing: 12) {
                MetricTile(
                    title: "Zachmurzenie",
                    value: WeatherFormat.percent(current.cloudCover),
                    systemImage: "cloud"
                )
                MetricTile(
                    title: "Szansa opadów",
                    value: current.precipitationProbability.map(WeatherFormat.percent) ?? "–",
                    systemImage: "umbrella"
                )
            }
        }
        .cardStyle()
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.groupedBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
