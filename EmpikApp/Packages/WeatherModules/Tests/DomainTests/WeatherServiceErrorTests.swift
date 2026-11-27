import Domain
import Foundation
import Testing

struct WeatherServiceErrorTests {
    private struct SampleError: LocalizedError {
        var errorDescription: String? { "Coś poszło nie tak" }
    }

    @Test func keepsWeatherServiceErrorsUnchanged() {
        #expect(WeatherServiceError(WeatherServiceError.offline) == .offline)
        #expect(WeatherServiceError(WeatherServiceError.general(message: "Błąd")) == .general(message: "Błąd"))
    }

    @Test func wrapsOtherErrorsAsGeneral() {
        #expect(WeatherServiceError(SampleError()) == .general(message: "Coś poszło nie tak"))
    }

    @Test func providesMessages() {
        #expect(WeatherServiceError.offline.message == "Brak połączenia z internetem.")
        #expect(WeatherServiceError.general(message: "Serwer nie odpowiada").message == "Serwer nie odpowiada")
    }

    @Test(arguments: [WeatherServiceError.offline, .general(message: "Błąd serwera")])
    func errorDescriptionMatchesMessage(error: WeatherServiceError) {
        #expect(error.errorDescription == error.message)
        #expect(error.localizedDescription == error.message)
    }
}
