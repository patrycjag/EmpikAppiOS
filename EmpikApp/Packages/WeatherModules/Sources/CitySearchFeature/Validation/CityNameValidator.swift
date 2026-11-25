import Foundation

public struct CityNameValidator: Sendable {
    public enum Failure: Error, Equatable, Sendable {
        case containsDigits
        case containsInvalidCharacters
    }

    public enum ValidationResult: Equatable, Sendable {
        case empty
        case valid(normalized: String)
        case invalid(Failure)
    }

    public init() {}

    public func validate(_ input: String) -> ValidationResult {
        let name = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacing(/\ +/, with: " ")
            .precomposedStringWithCanonicalMapping

        if name.isEmpty { return .empty }
        if name.contains(where: \.isNumber) { return .invalid(.containsDigits) }
        if name.contains(/[^\p{L}\p{M} -]/) { return .invalid(.containsInvalidCharacters) }
        return .valid(normalized: name)
    }
}
