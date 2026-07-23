import XCTest
@testable import Quicksilver

/// Basic persona contract tests.
/// These verify initialization and protocol conformance without UI or network.
final class PersonaTests: XCTestCase {
    func testQuicksilverPersonaIdentity() {
        let persona = QuicksilverPersona()
        XCTAssertEqual(persona.id, "quicksilver")
        XCTAssertFalse(persona.name.isEmpty)
        XCTAssertFalse(persona.systemPrompt.isEmpty)
        XCTAssertEqual(persona.accentColorName, "quicksilverCyan")
    }

    func testForgePersonaIdentity() {
        let persona = ForgePersona()
        XCTAssertEqual(persona.id, "forge")
        XCTAssertEqual(persona.name, "Forge")
    }

    func testEternalPersonaIdentity() {
        let persona = EternalPersona()
        XCTAssertEqual(persona.id, "eternal")
        XCTAssertEqual(persona.name, "Eternal")
    }

    func testAllPersonasAreDistinct() {
        let ids = [
            QuicksilverPersona().id,
            ForgePersona().id,
            EternalPersona().id
        ]
        XCTAssertEqual(Set(ids).count, 3, "Persona IDs must be unique")
    }
}
