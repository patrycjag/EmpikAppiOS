import Foundation

public struct TestError: LocalizedError, Equatable {
    public let message: String

    public init(_ message: String = "Test error") {
        self.message = message
    }

    public var errorDescription: String? {
        message
    }
}
