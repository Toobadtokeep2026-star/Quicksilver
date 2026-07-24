import XCTest
@testable import Core
@testable import Memory

@MainActor
final class MemoryLifecycleTests: XCTestCase {

    func testDeleteRemovesItem() async {
        let store = InMemoryMemoryStore()
        let bus = EventBus()
        let logger = LoggerService()
        let manager = MemoryManager(store: store, eventBus: bus, logger: logger)

        await manager.set(key: "test.1", value: "hello", category: .temporary)
        XCTAssertEqual(manager.items.count, 1)

        let id = manager.items[0].id
        await manager.delete(id: id)
        XCTAssertTrue(manager.items.isEmpty)
    }

    func testClearAllEmptiesStore() async {
        let store = InMemoryMemoryStore()
        let bus = EventBus()
        let logger = LoggerService()
        let manager = MemoryManager(store: store, eventBus: bus, logger: logger)

        await manager.set(key: "a", value: "1", category: .temporary)
        await manager.set(key: "b", value: "2", category: .temporary)
        XCTAssertEqual(manager.items.count, 2)

        await manager.clearAll()
        XCTAssertTrue(manager.items.isEmpty)
    }

    func testExportJSONProducesValidPayload() async throws {
        let store = InMemoryMemoryStore()
        let bus = EventBus()
        let logger = LoggerService()
        let manager = MemoryManager(store: store, eventBus: bus, logger: logger)

        await manager.set(key: "note", value: "export me", category: .temporary)
        let json = try manager.exportJSON()
        XCTAssertTrue(json.contains("export me"))
        XCTAssertTrue(json.contains("note"))
    }
}
