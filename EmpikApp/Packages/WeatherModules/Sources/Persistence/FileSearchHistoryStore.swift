import Domain
import Foundation
import OSLog

public actor FileSearchHistoryStore: SearchHistoryStoring {
    private let fileURL: URL
    private let maxItems: Int
    private var cache: [Location]?

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WeatherModules", category: "SearchHistory")

    public init(fileURL: URL = FileSearchHistoryStore.defaultFileURL, maxItems: Int = 10) {
        self.fileURL = fileURL
        self.maxItems = maxItems
    }

    public static var defaultFileURL: URL {
        let directory = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent("search_history.json")
    }

    public func load() throws -> [Location] {
        if let cache {
            return cache
        }

        let items = readFromDisk()
        cache = items
        return items
    }

    public func add(_ location: Location) throws -> [Location] {
        var items = try load()
        items.removeAll { $0.id == location.id }
        items.insert(location, at: 0)
        try save(Array(items.prefix(maxItems)))
        return try load()
    }

    public func remove(locationID: Location.ID) throws -> [Location] {
        var items = try load()
        items.removeAll { $0.id == locationID }
        try save(items)
        return items
    }

    public func clear() throws {
        try save([])
    }

    private func readFromDisk() -> [Location] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Location].self, from: data)
        } catch {
            Self.logger.error("Failed to read search history: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private func save(_ items: [Location]) throws {
        let data = try JSONEncoder().encode(items)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
        cache = items
    }
}
