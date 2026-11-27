import CitySearchFeature
import Domain
import TestSupport
import Testing

@MainActor
struct SearchHistoryModelTests {
    @Test func startsEmpty() {
        #expect(SearchHistoryModel(store: InMemorySearchHistoryStore()).items.isEmpty)
    }

    @Test func loadPublishesStoredItems() async {
        let model = SearchHistoryModel(store: InMemorySearchHistoryStore(items: [Fixtures.warsaw, Fixtures.krakow]))

        await model.load()

        #expect(model.items == [Fixtures.warsaw, Fixtures.krakow])
    }

    @Test func failedLoadKeepsHistoryEmpty() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw])
        await store.fail(.load)
        let model = SearchHistoryModel(store: store)

        await model.load()

        #expect(model.items.isEmpty)
    }

    @Test func addPutsLocationFirst() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw])
        let model = SearchHistoryModel(store: store)

        model.add(Fixtures.krakow)

        let updated = await waitUntil { model.items == [Fixtures.krakow, Fixtures.warsaw] }
        #expect(updated)
        #expect(await store.items == [Fixtures.krakow, Fixtures.warsaw])
    }

    @Test func removeUpdatesItemsImmediately() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw, Fixtures.krakow])
        let model = SearchHistoryModel(store: store)
        await model.load()

        model.remove([Fixtures.warsaw])

        #expect(model.items == [Fixtures.krakow])
        await model.load()
        #expect(await store.items == [Fixtures.krakow])
    }

    @Test func removingNothingDoesNotTouchTheStore() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw])
        let model = SearchHistoryModel(store: store)

        model.remove([])
        await model.load()

        #expect(await store.removeCallCount == 0)
        #expect(model.items == [Fixtures.warsaw])
    }

    @Test func failedRemoveRestoresStoredItems() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw, Fixtures.krakow])
        let model = SearchHistoryModel(store: store)
        await model.load()
        await store.fail(.remove)

        model.remove([Fixtures.warsaw])
        #expect(model.items == [Fixtures.krakow])

        let restored = await waitUntil { model.items == [Fixtures.warsaw, Fixtures.krakow] }
        #expect(restored)
    }

    @Test func clearRemovesEverything() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw, Fixtures.krakow])
        let model = SearchHistoryModel(store: store)
        await model.load()

        model.clear()

        let cleared = await waitUntil { model.items.isEmpty }
        #expect(cleared)
        #expect(await store.items.isEmpty)
    }

    @Test func failedClearKeepsStoredItems() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw])
        let model = SearchHistoryModel(store: store)
        await model.load()
        await store.fail(.clear)

        model.clear()
        await model.load()

        #expect(model.items == [Fixtures.warsaw])
    }

    @Test func operationsRunInOrder() async {
        let store = InMemorySearchHistoryStore(items: [Fixtures.warsaw])
        let model = SearchHistoryModel(store: store)

        model.add(Fixtures.krakow)
        model.remove([Fixtures.krakow])
        model.add(Fixtures.gdansk)
        await model.load()

        #expect(model.items == [Fixtures.gdansk, Fixtures.warsaw])
        #expect(await store.items == [Fixtures.gdansk, Fixtures.warsaw])
    }
}
