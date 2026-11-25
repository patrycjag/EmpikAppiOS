import DesignSystem
import Domain
import SwiftUI

public struct CitySearchView: View {
    @Bindable private var viewModel: CitySearchViewModel
    private let onSelect: @MainActor (Location) -> Void

    public init(viewModel: CitySearchViewModel, onSelect: @escaping @MainActor (Location) -> Void) {
        self.viewModel = viewModel
        self.onSelect = onSelect
    }

    public var body: some View {
        List {
            content
        }
        .listStyle(.insetGrouped)
        .overlay {
            overlay
        }
        .animation(.default, value: viewModel.state)
        .navigationTitle("Pogoda")
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Wpisz nazwę miejscowości"
        )
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
        .task(id: viewModel.searchKey) {
            await viewModel.search()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case let .tooShort(minimumLength):
            hint("Wpisz co najmniej \(minimumLength) znaki, aby wyszukać.", systemImage: "character.cursor.ibeam")

        case let .results(locations):
            Section("Wyniki wyszukiwania") {
                ForEach(locations) { location in
                    row(for: location, systemImage: "mappin.and.ellipse")
                }
            }

        case .idle, .loading, .empty, .failure:
            EmptyView()
        }
    }

    private func hint(_ text: String, systemImage: String) -> some View {
        Section {
            Label(text, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func row(for location: Location, systemImage: String) -> some View {
        Button {
            onSelect(location)
        } label: {
            LocationRow(location: location, systemImage: systemImage)
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "Wyszukaj miejscowość",
                systemImage: "magnifyingglass",
                description: Text("Wpisz nazwę miasta, aby sprawdzić prognozę pogody.")
            )

        case .loading:
            ProgressView("Szukam…")

        case let .empty(query):
            UnavailableStateView(
                title: "Brak wyników",
                systemImage: "mappin.slash",
                message: "Nie znaleźliśmy miejscowości „\(query)”. Sprawdź pisownię i spróbuj ponownie."
            ) {
                viewModel.retry()
            }

        case let .failure(error):
            UnavailableStateView(error: error) {
                viewModel.retry()
            }

        default:
            EmptyView()
        }
    }
}
