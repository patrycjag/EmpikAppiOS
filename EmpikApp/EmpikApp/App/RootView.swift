import CitySearchFeature
import Domain
import ForecastFeature
import SwiftUI

struct RootView: View {
    private let dependencies: AppDependencies
    @State private var router = AppRouter()
    @State private var searchViewModel: CitySearchViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _searchViewModel = State(
            initialValue: CitySearchViewModel(
                locationSearch: dependencies.locationSearch,
                historyStore: dependencies.historyStore
            )
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            CitySearchView(viewModel: searchViewModel) { location in
                router.showForecast(for: location)
            }
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case let .forecast(location):
            ForecastView(
                viewModel: ForecastViewModel(location: location, forecastProvider: dependencies.forecastProvider)
            )
        }
    }
}
