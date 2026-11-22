import Foundation
import Testing

@testable import FirstTask

struct PendingTaskStoreTests {

    private let store = PendingTaskStore(directoryURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true))

    @Test
    func loadReturnsEmptyWhenNothingIsQueued() {
        #expect(store.load().isEmpty)
    }

    @Test
    func loadReturnsAddedTasksInCreationOrder() throws {
        let later = PendingTask(title: "later", memo: "", createdAt: Date(timeIntervalSince1970: 200))
        let earlier = PendingTask(title: "earlier", memo: "https://example.com", createdAt: Date(timeIntervalSince1970: 100))
        try store.add(later)
        try store.add(earlier)

        #expect(store.load() == [earlier, later])
    }

    @Test
    func removeDeletesOnlyTheGivenTask() throws {
        let first = PendingTask(title: "first", memo: "")
        let second = PendingTask(title: "second", memo: "")
        try store.add(first)
        try store.add(second)

        store.remove(first)

        #expect(store.load() == [second])
    }
}
