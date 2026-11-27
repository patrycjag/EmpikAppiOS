import Foundation
import Networking
import TestSupport
import Testing

struct HTTPClientTests {
    private struct Payload: Decodable, Equatable, Sendable {
        let name: String
        let value: Int
    }

    private struct FailingRequestBuilder: RequestBuilding {
        func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
            throw NetworkError.general(message: "Nieprawidłowy adres zapytania.")
        }
    }

    private let endpoint = Endpoint(baseURL: URL(string: "https://api.example.com")!, path: "v1/data")

    @Test(arguments: [200, 299])
    func decodesSuccessfulResponse(statusCode: Int) async throws {
        let client = HTTPClientStub(statusCode: statusCode, json: #"{"name":"temp","value":21}"#)

        let payload = try await client.get(endpoint, as: Payload.self)

        #expect(payload == Payload(name: "temp", value: 21))
        #expect(client.lastRequest?.url?.absoluteString == "https://api.example.com/v1/data")
        #expect(client.lastRequest?.httpMethod == "GET")
    }

    @Test(arguments: [199, 301, 404, 500])
    func throwsForNonSuccessStatusCodes(statusCode: Int) async {
        let client = HTTPClientStub(statusCode: statusCode, json: #"{"name":"temp","value":21}"#)

        await #expect(throws: NetworkError.general(message: "Serwer zwrócił błąd (kod \(statusCode)).")) {
            try await client.get(endpoint, as: Payload.self)
        }
    }

    @Test func throwsWhenResponseCannotBeDecoded() async {
        let client = HTTPClientStub(json: #"{"unexpected":true}"#)

        await #expect(throws: NetworkError.general(message: "Nie udało się odczytać odpowiedzi serwera.")) {
            try await client.get(endpoint, as: Payload.self)
        }
    }

    @Test func propagatesTransportErrors() async {
        let client = HTTPClientStub(response: .failure(NetworkError.offline))

        await #expect(throws: NetworkError.offline) {
            try await client.get(endpoint, as: Payload.self)
        }
    }

    @Test func propagatesRequestBuildingErrorsWithoutSendingRequest() async {
        let client = HTTPClientStub(json: "{}")

        await #expect(throws: NetworkError.general(message: "Nieprawidłowy adres zapytania.")) {
            try await client.get(endpoint, as: Payload.self, requestBuilder: FailingRequestBuilder())
        }
        #expect(client.requests.value.isEmpty)
    }

    @Test func networkErrorDescriptions() {
        #expect(NetworkError.offline.errorDescription == "Brak połączenia z internetem.")
        #expect(NetworkError.general(message: "Błąd").errorDescription == "Błąd")
    }
}
