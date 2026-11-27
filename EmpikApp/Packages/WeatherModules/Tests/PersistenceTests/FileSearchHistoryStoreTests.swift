import Domain
import Foundation
import Persistence
import TestSupport
import Testing

final class FileSearchHistoryStoreTests: Sendable {
    private let directory: URL

    init() {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FileSearchHistoryStoreTests-\(UUID().uuidString)", isDirectory: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    private var fileURL: URL {
        directory.appendingPathComponent("nested/history.json")
    }

    private func makeStore(maxItems: Int = 10) -> FileSearchHistoryStore {
        FileSearchHistoryStore(fileURL: fileURL, maxItems: maxItems)
    }

    @Test func loadReturnsEmptyHistoryWhenFileDoesNotExist() async throws {
        #expect(try await makeStore().load().isEmpty)
    }

    @Test func addInsertsMostRecentLocationFirst() async throws {
        let store = makeStore()

        _ = try await store.add(Fixtures.warsaw)
        let items = try await store.add(Fixtures.krakow)

        #expect(items == [Fixtures.krakow, Fixtures.warsaw])
        #expect(try await store.load() == items)
    }

    @Test func addMovesExistingLocationToTop() async throws {
        let store = makeStore()

        _ = try await store.add(Fixtures.warsaw)
        _ = try await store.add(Fixtures.krakow)
        let items = try await store.add(Fixtures.warsaw)

        #expect(items == [Fixtures.warsaw, Fixtures.krakow])
    }

    @Test func addKeepsAtMostMaxItems() async throws {
        let store = makeStore(maxItems: 2)

        _ = try await store.add(Fixtures.warsaw)
        _ = try await store.add(Fixtures.krakow)
        let items = try await store.add(Fixtures.gdansk)

        #expect(items == [Fixtures.gdansk, Fixtures.krakow])
    }

    @Test func historyPersistsBetweenStoreInstances() async throws {
        _ = try await makeStore().add(Fixtures.warsaw)
        _ = try await makeStore().add(Fixtures.krakow)

        #expect(FileManager.default.fileExists(atPath: fileURL.path))
        #expect(try await makeStore().load() == [Fixtures.krakow, Fixtures.warsaw])
    }

    @Test func removeDeletesGivenLocations() async throws {
        let store = makeStore()
        _ = try await store.add(Fixtures.warsaw)
        _ = try await store.add(Fixtures.krakow)
        _ = try await store.add(Fixtures.gdansk)

        let items = try await store.remove(locationIDs: [Fixtures.warsaw.id, Fixtures.gdansk.id])

        #expect(items == [Fixtures.krakow])
        #expect(try await makeStore().load() == [Fixtures.krakow])
    }

    @Test func clearRemovesAllLocations() async throws {
        let store = makeStore()
        _ = try await store.add(Fixtures.warsaw)

        try await store.clear()

        #expect(try await store.load().isEmpty)
        #expect(try await makeStore().load().isEmpty)
    }

    @Test func corruptedFileIsTreatedAsEmptyHistory() async throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not json".utf8).write(to: fileURL)
        let store = makeStore()

        #expect(try await store.load().isEmpty)
        #expect(try await store.add(Fixtures.warsaw) == [Fixtures.warsaw])
        #expect(try await makeStore().load() == [Fixtures.warsaw])
    }

    @Test func defaultFileLivesInApplicationSupport() {
        let url = FileSearchHistoryStore.defaultFileURL
        #expect(url.lastPathComponent == "search_history.json")
    }
}
