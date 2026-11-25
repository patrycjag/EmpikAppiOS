import SwiftUI

@main
struct WeatherApp: App {
    private let dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
