extension CityNameValidator.Failure {
    var message: String {
        switch self {
        case .containsDigits:
            "Nazwa miejscowości nie może zawierać cyfr."
        case .containsInvalidCharacters:
            "Dozwolone są tylko litery, spacja i myślnik."
        }
    }
}
