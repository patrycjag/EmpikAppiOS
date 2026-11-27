import Foundation
@testable import Networking
import TestSupport
import Testing

struct URLSessionHTTPClientTests {
    private func makeClient() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSessionHTTPClient(session: URLSession(configuration: configuration))
    }

    private func makeRequest(stubbing stub: StubURLProtocol.Stub) -> URLRequest {
        let url = URL(string: "https://stub.test/\(UUID().uuidString)")!
        StubURLProtocol.register(stub, for: url)
        return URLRequest(url: url)
    }

    @Test func returnsStatusCodeAndBody() async throws {
        let body = Data(#"{"ok":true}"#.utf8)
        let request = makeRequest(stubbing: .response(statusCode: 404, data: body))

        let response = try await makeClient().perform(request)

        #expect(response.statusCode == 404)
        #expect(response.data == body)
    }

    @Test func mapsConnectionErrorsToOffline() async {
        let request = makeRequest(stubbing: .failure(URLError(.notConnectedToInternet)))

        await #expect(throws: NetworkError.offline) {
            try await makeClient().perform(request)
        }
    }

    @Test func rejectsNonHTTPResponses() async {
        let request = makeRequest(stubbing: .nonHTTPResponse)

        await #expect(throws: NetworkError.general(message: "Nieprawidłowa odpowiedź serwera.")) {
            try await makeClient().perform(request)
        }
    }

    @Test(arguments: [
        URLError(.notConnectedToInternet),
        URLError(.networkConnectionLost),
        URLError(.dataNotAllowed),
    ])
    func mapsConnectivityErrorsToOffline(error: URLError) {
        #expect(URLSessionHTTPClient.map(error) as? NetworkError == .offline)
    }

    @Test func mapsCancelledURLErrorToCancellationError() {
        #expect(URLSessionHTTPClient.map(URLError(.cancelled)) is CancellationError)
    }

    @Test func keepsCancellationError() {
        #expect(URLSessionHTTPClient.map(CancellationError()) is CancellationError)
    }

    @Test func mapsOtherURLErrorsToGeneral() {
        let error = URLError(.timedOut)
        #expect(URLSessionHTTPClient.map(error) as? NetworkError == .general(message: error.localizedDescription))
    }

    @Test func mapsNonURLErrorsToGeneral() {
        #expect(URLSessionHTTPClient.map(TestError("Boom")) as? NetworkError == .general(message: "Boom"))
    }
}

final class StubURLProtocol: URLProtocol {
    enum Stub: Sendable {
        case response(statusCode: Int, data: Data)
        case nonHTTPResponse
        case failure(URLError)
    }

    private static let stubs = LockIsolated<[URL: Stub]>([:])

    static func register(_ stub: Stub, for url: URL) {
        stubs.withValue { $0[url] = stub }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url, let stub = Self.stubs.value[url] else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        switch stub {
        case let .response(statusCode, data):
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)

        case .nonHTTPResponse:
            let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocolDidFinishLoading(self)

        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
