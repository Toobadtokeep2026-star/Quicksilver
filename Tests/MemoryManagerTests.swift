import XCTest
@testable import Quicksilver

@MainActor
final class MemoryManagerTests: XCTestCase {
    func testSetAndRetrievePreference() async {
        let store = UserDefaultsMemoryStore(defaults: UserDefaults(suiteName: "test.memory")!)
        let bus = EventBus()
        let logger = LoggerService()
        let manager = MemoryManager(store: store, eventBus: bus, logger: logger)

        await manager.set(key: "theme", value: "dark", category: .preference)
        await manager.load()

        XCTAssertEqual(manager.value(for: "theme", category: .preference), "dark")
    }

    func testDeleteItem() async {
        let store = UserDefaultsMemoryStore(defaults: UserDefaults(suiteName: "test.memory.delete")!)
        let bus = EventBus()
        let logger = LoggerService()
        let manager = MemoryManager(store: store, eventBus: bus, logger: logger)

        await manager.set(key: "temp", value: "1", category: .temporary)
        await manager.load()
        XCTAssertEqual(manager.items.count, 1)

        if let id = manager.items.first?.id {
            await manager.delete(id: id)
            XCTAssertTrue(manager.items.isEmpty)
        } else {
            XCTFail("No item created")
        }
    }
}
