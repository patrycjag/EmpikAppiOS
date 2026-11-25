import Domain
import SwiftUI

public struct UnavailableStateView: View {
    private let title: String
    private let systemImage: String
    private let message: String
    private let retryTitle: String
    private let retry: @MainActor () -> Void

    public init(
        title: String,
        systemImage: String,
        message: String,
        retryTitle: String = "Spróbuj ponownie",
        retry: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
        self.retryTitle = retryTitle
        self.retry = retry
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button(retryTitle, systemImage: "arrow.clockwise") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

public extension UnavailableStateView {
    init(error: WeatherServiceError, retry: @escaping @MainActor () -> Void) {
        switch error {
        case .offline:
            self.init(
                title: "Brak połączenia z internetem",
                systemImage: "wifi.slash",
                message: "Sprawdź połączenie z siecią i spróbuj ponownie.",
                retry: retry
            )
        case let .general(message):
            self.init(
                title: "Wystąpił błąd",
                systemImage: "exclamationmark.triangle",
                message: message,
                retry: retry
            )
        }
    }
}

#Preview("Offline") {
    UnavailableStateView(error: .offline) {}
}

#Preview("Error") {
    UnavailableStateView(error: .general(message: "Serwer zwrócił błąd (kod 500).")) {}
}
