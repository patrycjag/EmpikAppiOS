import Domain
import Networking
import OpenMeteo

struct AppDependencies {
    let locationSearch: any LocationSearching

    static func live() -> AppDependencies {
        let httpClient = URLSessionHTTPClient()
        return AppDependencies(
            locationSearch: OpenMeteoLocationService(client: httpClient)
        )
    }
}
