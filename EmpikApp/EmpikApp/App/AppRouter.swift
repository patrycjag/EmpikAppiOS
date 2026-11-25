import Domain
import Observation

nonisolated enum Route: Hashable {
    case forecast(Location)
}

@Observable
final class AppRouter {
    var path: [Route] = []

    func showForecast(for location: Location) {
        path.append(.forecast(location))
    }
}
