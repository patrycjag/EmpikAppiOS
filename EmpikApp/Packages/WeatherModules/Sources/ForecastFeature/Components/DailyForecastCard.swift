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

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)

            WeatherSymbol(condition: day.condition)
                .font(.title3)
                .frame(width: 32)

            Text(day.precipitationProbability.map(WeatherFormat.percent) ?? "–")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 40, alignment: .trailing)

            Text(WeatherFormat.temperature(day.minTemperature))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 40, alignment: .trailing)

            Text(WeatherFormat.temperature(day.maxTemperature))
                .fontWeight(.semibold)
                .monospacedDigit()
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}
