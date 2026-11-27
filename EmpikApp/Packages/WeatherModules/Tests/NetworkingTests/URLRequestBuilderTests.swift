import Foundation
import Networking
import Testing

struct URLRequestBuilderTests {
    private let builder = URLRequestBuilder()
    private let baseURL = URL(string: "https://api.example.com")!

    @Test func buildsGetRequestWithQueryItems() throws {
        let endpoint = Endpoint(
            baseURL: baseURL,
            path: "v1/search",
            queryItems: [.init("name", "Warszawa"), .init("count", "10")],
            timeout: 30
        )

        let request = try builder.makeRequest(for: endpoint)

        #expect(request.url?.absoluteString == "https://api.example.com/v1/search?name=Warszawa&count=10")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.timeoutInterval == 30)
    }

    @Test func omitsQueryWhenThereAreNoItems() throws {
        let request = try builder.makeRequest(for: Endpoint(baseURL: baseURL, path: "v1/forecast"))

        #expect(request.url?.absoluteString == "https://api.example.com/v1/forecast")
        #expect(request.timeoutInterval == 15)
    }

    @Test func percentEncodesQueryValues() throws {
        let endpoint = Endpoint(baseURL: baseURL, path: "v1/search", queryItems: [.init("name", "Nowy Sącz")])

        let request = try builder.makeRequest(for: endpoint)

        #expect(request.url?.absoluteString.hasSuffix("?name=Nowy%20S%C4%85cz") == true)
    }
}
