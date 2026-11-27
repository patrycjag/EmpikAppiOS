import DesignSystem
import Domain
import SwiftUI

public struct ForecastView: View {
    @State private var viewModel: ForecastViewModel

    public init(viewModel: ForecastViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            content
        }
        .background(Color.groupedBackground)
        .refreshable {
            await viewModel.refresh()
        }
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: viewModel.state)
        .animation(.default, value: viewModel.dailyState)
        .animation(.default, value: viewModel.refreshError)
        .onChange(of: viewModel.refreshError) { _, error in
            // Pull-to-refresh failures only show a banner, so let VoiceOver users know too.
            guard error != nil else { return }
            AccessibilityNotification.Announcement("Nie udało się odświeżyć prognozy").post()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Ładowanie prognozy…")
                .containerRelativeFrame([.horizontal, .vertical])

        case let .failure(error):
            UnavailableStateView(error: error) {
                viewModel.reload()
            }
            .containerRelativeFrame([.horizontal, .vertical])

        case let .loaded(forecast):
            VStack(spacing: 16) {
                if let refreshError = viewModel.refreshError {
                    RefreshErrorBanner(error: refreshError)
                }

                CurrentConditionsCard(location: viewModel.location, current: forecast.current)

                HourlyForecastCard(hours: forecast.hourly, timeZone: forecast.timeZone)

                DailyForecastCard(state: viewModel.dailyState, timeZone: forecast.timeZone) {
                    viewModel.retryDailyForecast()
                }
            }
            .padding()
        }
    }
}

private struct RefreshErrorBanner: View {
    let error: WeatherServiceError

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nie udało się odświeżyć prognozy")
                    .font(.footnote.weight(.semibold))
                Text(error.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
