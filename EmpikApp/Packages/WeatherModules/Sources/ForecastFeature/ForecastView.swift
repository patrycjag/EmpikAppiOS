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
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: viewModel.state)
        .animation(.default, value: viewModel.dailyState)
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
