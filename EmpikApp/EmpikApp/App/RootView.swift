import CitySearchFeature
import SwiftUI

struct RootView: View {
    @State private var searchViewModel: CitySearchViewModel

    init(dependencies: AppDependencies) {
        _searchViewModel = State(
            initialValue: CitySearchViewModel(
                locationSearch: dependencies.locationSearch
            )
        )
    }

    var body: some View {
        NavigationStack {
            CitySearchView(viewModel: searchViewModel) { _ in }
        }
    }
}
