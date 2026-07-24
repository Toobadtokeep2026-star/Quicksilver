import XCTest
@testable import Core
@testable import Memory

final class MemoryQueryTests: XCTestCase {

    let items: [MemoryItem] = [
        MemoryItem(key: "pref.theme", category: .preference, value: "dark", importance: 0.8, personaScope: nil),
        MemoryItem(key: "note.1", category: .temporary, value: "scratch", importance: 0.2, personaScope: "forge"),
        MemoryItem(key: "proj.alpha", category: .project, value: "ship it", importance: 0.9, personaScope: "quicksilver"),
        MemoryItem(key: "conv.1", category: .conversation, value: "hello", importance: 0.4, personaScope: nil)
    ]

    func testFilterByCategory() {
        let result = MemoryQuery(category: .project).apply(to: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.key, "proj.alpha")
    }

    func testFilterByPersonaScope() {
        let result = MemoryQuery(personaScope: "forge").apply(to: items)
        // shared (nil) + forge-scoped
        XCTAssertEqual(result.count, 3)
    }

    func testMinimumImportance() {
        let result = MemoryQuery(minimumImportance: 0.7).apply(to: items)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.key, "proj.alpha") // highest importance first
    }

    func testKeyPrefix() {
        let result = MemoryQuery(keyPrefix: "pref.").apply(to: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.key, "pref.theme")
    }

    func testLimit() {
        let result = MemoryQuery(limit: 2).apply(to: items)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].importance, 0.9, accuracy: 0.001)
    }
}
