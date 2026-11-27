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
                .accessibilityAddTraits(.isHeader)

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

    @ScaledMetric(relativeTo: .title2) private var symbolHeight: CGFloat = 30

    private var precipitation: String? {
        hour.precipitationProbability.map(WeatherFormat.percent)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            WeatherSymbol(condition: hour.condition, isDay: hour.isDay)
                .font(.title2)
                .frame(height: symbolHeight)

            Text(WeatherFormat.temperature(hour.temperature))
                .font(.body.weight(.semibold))
                .monospacedDigit()

            Label(precipitation ?? "–", systemImage: "drop.fill")
                .labelStyle(.titleAndIcon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.blue)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenDescription)
    }

    private var spokenDescription: String {
        var parts = [
            title,
            WeatherFormat.temperature(hour.temperature),
            hour.condition.displayName,
        ]
        if let precipitation {
            parts.append("szansa opadów \(precipitation)")
        }
        return parts.joined(separator: ", ")
    }
}
