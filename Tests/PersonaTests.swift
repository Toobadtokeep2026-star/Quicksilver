import XCTest
@testable import Personas

/// Configuration surface tests.
/// The legacy Persona protocol has been removed; PersonaConfiguration is the sole source of truth.
final class PersonaTests: XCTestCase {
    func testQuicksilverConfiguration() {
        let config = PersonaConfiguration.quicksilver
        XCTAssertEqual(config.id, "quicksilver")
        XCTAssertFalse(config.displayName.isEmpty)
        XCTAssertFalse(config.systemPrompt.isEmpty)
        XCTAssertEqual(config.accentColorName, "quicksilverCyan")
    }

    func testForgeConfiguration() {
        let config = PersonaConfiguration.forge
        XCTAssertEqual(config.id, "forge")
        XCTAssertEqual(config.displayName, "Forge")
    }

    func testEternalConfiguration() {
        let config = PersonaConfiguration.eternal
        XCTAssertEqual(config.id, "eternal")
        XCTAssertEqual(config.displayName, "Eternal")
    }

    func testAllConfigurationsAreDistinct() {
        let ids = PersonaConfiguration.all.map(\.id)
        XCTAssertEqual(Set(ids).count, 3, "Persona configuration IDs must be unique")
    }

    func testAllContainsTheThreeCanonicalConfigs() {
        let ids = Set(PersonaConfiguration.all.map(\.id))
        XCTAssertTrue(ids.contains("quicksilver"))
        XCTAssertTrue(ids.contains("forge"))
        XCTAssertTrue(ids.contains("eternal"))
    }
}
