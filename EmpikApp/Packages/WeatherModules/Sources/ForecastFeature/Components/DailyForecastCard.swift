import DesignSystem
import Domain
import SwiftUI

struct DailyForecastCard: View {
    let state: ForecastViewModel.DailyState
    let timeZone: TimeZone
    let retry: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Najbliższe dni", systemImage: "calendar")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            switch state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)

            case let .failure(error):
                VStack(spacing: 12) {
                    Text(error.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Spróbuj ponownie", systemImage: "arrow.clockwise") {
                        retry()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

            case let .loaded(days):
                VStack(spacing: 0) {
                    ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                        DayRow(
                            title: index == 0 ? "Dziś" : WeatherFormat.weekday(day.date, timeZone: timeZone),
                            day: day
                        )
                        if index < days.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

private struct DayRow: View {
    let title: String
    let day: DailyForecast

    @ScaledMetric(relativeTo: .title3) private var symbolWidth: CGFloat = 32
    @ScaledMetric(relativeTo: .caption) private var precipitationWidth: CGFloat = 40
    @ScaledMetric(relativeTo: .body) private var temperatureWidth: CGFloat = 40

    private var precipitation: String? {
        day.precipitationProbability.map(WeatherFormat.percent)
    }

    private var minTemperature: String {
        WeatherFormat.temperature(day.minTemperature)
    }

    private var maxTemperature: String {
        WeatherFormat.temperature(day.maxTemperature)
    }

    var body: some View {
        // Falls back to a two-line layout when the columns don't fit, e.g. with large Dynamic Type sizes.
        ViewThatFits(in: .horizontal) {
            singleLineLayout
            stackedLayout
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenDescription)
    }

    private var singleLineLayout: some View {
        HStack(spacing: 12) {
            titleText
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            symbol
                .frame(width: symbolWidth)

            precipitationText
                .frame(width: precipitationWidth, alignment: .trailing)

            minTemperatureText
                .frame(width: temperatureWidth, alignment: .trailing)

            maxTemperatureText
                .frame(width: temperatureWidth, alignment: .trailing)
        }
    }

    private var stackedLayout: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                titleText
                    .frame(maxWidth: .infinity, alignment: .leading)
                symbol
            }

            HStack(spacing: 12) {
                precipitationText
                Spacer(minLength: 0)
                minTemperatureText
                maxTemperatureText
            }
        }
    }

    private var titleText: some View {
        Text(title)
    }

    private var symbol: some View {
        WeatherSymbol(condition: day.condition)
            .font(.title3)
    }

    private var precipitationText: some View {
        Text(precipitation ?? "–")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
    }

    private var minTemperatureText: some View {
        Text(minTemperature)
            .foregroundStyle(.secondary)
            .monospacedDigit()
    }

    private var maxTemperatureText: some View {
        Text(maxTemperature)
            .fontWeight(.semibold)
            .monospacedDigit()
    }

    private var spokenDescription: String {
        var parts = [
            title,
            day.condition.displayName,
            "temperatura od \(minTemperature) do \(maxTemperature)",
        ]
        if let precipitation {
            parts.append("szansa opadów \(precipitation)")
        }
        return parts.joined(separator: ", ")
    }
}
