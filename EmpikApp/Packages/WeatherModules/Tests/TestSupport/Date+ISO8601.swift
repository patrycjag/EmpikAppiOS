import Foundation

extension Date {
    /// Creates a date from an ISO 8601 string with an explicit offset, e.g. `"2025-11-26T11:00:00+01:00"`.
    /// Traps on invalid input, so a typo fails the test instead of silently producing a wrong date.
    public init(iso8601 string: String) {
        guard let date = ISO8601DateFormatter().date(from: string) else {
            preconditionFailure("Invalid ISO 8601 date: \(string)")
        }
        self = date
    }
}
