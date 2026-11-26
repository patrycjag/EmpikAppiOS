import DesignSystem
import Domain
import SwiftUI

public struct CitySearchView: View {
    @Bindable private var viewModel: CitySearchViewModel
    private let onSelect: @MainActor (Location) -> Void

    private var history: SearchHistoryModel {
        viewModel.history
    }

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
        .animation(.default, value: history.items)
        .navigationTitle("Pogoda")
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Wpisz nazwę miejscowości"
        )
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
        .task {
            await history.load()
        }
        .task(id: viewModel.searchRequest) {
            await viewModel.search(viewModel.searchRequest)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            historySection

        case let .tooShort(minimumLength):
            hint("Wpisz co najmniej \(minimumLength) znaki, aby wyszukać.", systemImage: "character.cursor.ibeam")
            historySection

        case let .invalid(failure):
            hint(failure.message, systemImage: "exclamationmark.circle", isError: true)
            historySection

        case let .results(locations):
            Section("Wyniki wyszukiwania") {
                ForEach(locations) { location in
                    row(for: location, systemImage: "mappin.and.ellipse")
                }
            }

        case .loading, .empty, .failure:
            EmptyView()
        }
    }

    @ViewBuilder
    private var historySection: some View {
        if !history.items.isEmpty {
            Section {
                ForEach(history.items) { location in
                    row(for: location, systemImage: "clock.arrow.circlepath")
                }
                .onDelete { offsets in
                    history.remove(offsets.map { history.items[$0] })
                }
            } header: {
                HStack {
                    Text("Ostatnio wyszukiwane")
                    Spacer()
                    Button("Wyczyść") {
                        history.clear()
                    }
                    .font(.footnote.weight(.semibold))
                }
                .textCase(nil)
            }
        }
    }

    private func hint(_ text: String, systemImage: String, isError: Bool = false) -> some View {
        Section {
            Label(text, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(isError ? Color.red : Color.secondary)
        }
    }

    private func row(for location: Location, systemImage: String) -> some View {
        Button {
            viewModel.select(location)
            onSelect(location)
        } label: {
            LocationRow(location: location, systemImage: systemImage)
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch viewModel.state {
        case .idle where history.items.isEmpty:
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
