import Foundation

public struct CityNameValidator: Sendable {
    public enum Failure: Error, Equatable, Sendable {
        case containsDigits
        case containsInvalidCharacters
    }

    public enum ValidationResult: Equatable, Sendable {
        case empty
        case tooShort(minimumLength: Int)
        case valid(normalized: String)
        case invalid(Failure)
    }

    public let minimumLength: Int

    public init(minimumLength: Int = 2) {
        self.minimumLength = minimumLength
    }

    public func validate(_ input: String) -> ValidationResult {
        let name = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacing(/\ +/, with: " ")
            .precomposedStringWithCanonicalMapping

        if name.isEmpty { return .empty }
        if name.count < minimumLength { return .tooShort(minimumLength: minimumLength) }
        if name.contains(where: \.isNumber) { return .invalid(.containsDigits) }
        if name.contains(/[^\p{L}\p{M} -]/) { return .invalid(.containsInvalidCharacters) }
        return .valid(normalized: name)
    }
}
