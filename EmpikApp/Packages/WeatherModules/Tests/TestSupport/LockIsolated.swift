import Foundation

public final class LockIsolated<Value>: @unchecked Sendable {
    private var storage: Value
    private let lock = NSLock()

    public init(_ value: Value) {
        storage = value
    }

    public var value: Value {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    public func setValue(_ newValue: Value) {
        withValue { $0 = newValue }
    }

    @discardableResult
    public func withValue<T>(_ operation: (inout Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try operation(&storage)
    }
}
