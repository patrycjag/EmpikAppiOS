@testable import CitySearchFeature
import Testing

struct CityNameValidatorTests {
    private let validator = CityNameValidator()

    @Test(arguments: ["", "   ", "\n\t "])
    func emptyInputIsEmpty(input: String) {
        #expect(validator.validate(input) == .empty)
    }

    @Test func tooShortInputReportsMinimumLength() {
        #expect(validator.validate(" W ") == .tooShort(minimumLength: 2))
        #expect(CityNameValidator(minimumLength: 3).validate("Ło") == .tooShort(minimumLength: 3))
    }

    @Test(arguments: ["Warszawa", "Łódź", "Bielsko-Biała", "Nowy Sącz", "Zielona Góra", "Kędzierzyn-Koźle"])
    func acceptsValidNames(name: String) {
        #expect(validator.validate(name) == .valid(normalized: name))
    }

    @Test func trimsAndCollapsesSpaces() {
        #expect(validator.validate("  Nowy    Sącz  ") == .valid(normalized: "Nowy Sącz"))
    }

    @Test func normalizesToPrecomposedCharacters() throws {
        let decomposed = "Krako\u{0301}w"

        guard case let .valid(normalized) = validator.validate(decomposed) else {
            Issue.record("Expected a valid result")
            return
        }
        #expect(normalized.unicodeScalars.count == 6)
    }

    @Test(arguments: ["Warszawa2", "3city", "W4rs@w"])
    func rejectsDigits(name: String) {
        #expect(validator.validate(name) == .invalid(.containsDigits))
    }

    @Test(arguments: ["Kraków!", "Gdańsk_", "St. Louis", "O'Hare", "Łódź/Bałuty"])
    func rejectsInvalidCharacters(name: String) {
        #expect(validator.validate(name) == .invalid(.containsInvalidCharacters))
    }

    @Test func failuresHaveMessages() {
        #expect(CityNameValidator.Failure.containsDigits.message == "Nazwa miejscowości nie może zawierać cyfr.")
        #expect(CityNameValidator.Failure.containsInvalidCharacters.message == "Dozwolone są tylko litery, spacja i myślnik.")
    }
}
