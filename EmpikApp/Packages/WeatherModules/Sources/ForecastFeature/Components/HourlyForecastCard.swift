import DesignSystem
import Domain
import SwiftUI

struct HourlyForecastCard: View {
    let hours: [HourlyForecast]
    let timeZone: TimeZone

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Najbliższe godziny", systemImage: "clock")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
                        HourCell(
                            title: index == 0 ? "Teraz" : WeatherFormat.hour(hour.date, timeZone: timeZone),
                            hour: hour
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .cardStyle()
    }
}

private struct HourCell: View {
    let title: String
    let hour: HourlyForecast

    private var precipitation: String {
        hour.precipitationProbability.map(WeatherFormat.percent) ?? "–"
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            WeatherSymbol(condition: hour.condition, isDay: hour.isDay)
                .font(.title2)
                .frame(height: 30)

            Text(WeatherFormat.temperature(hour.temperature))
                .font(.body.weight(.semibold))
                .monospacedDigit()

            Label(precipitation, systemImage: "drop.fill")
                .labelStyle(.titleAndIcon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.blue)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(title): \(WeatherFormat.temperature(hour.temperature)), \(hour.condition.displayName), opady \(precipitation)"
        )
    }
}
