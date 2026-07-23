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
}
