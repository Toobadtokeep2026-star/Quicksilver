import XCTest
@testable import Core
@testable import Memory

final class MemoryScorerTests: XCTestCase {

    func testBaseScoreForTemporary() {
        let score = MemoryScorer.score(category: .temporary, value: "short")
        XCTAssertLessThan(score, 0.5)
    }

    func testBaseScoreForProjectHigherThanTemporary() {
        let temp = MemoryScorer.score(category: .temporary, value: "note")
        let project = MemoryScorer.score(category: .project, value: "note")
        XCTAssertGreaterThan(project, temp)
    }

    func testExplicitBoostWins() {
        let score = MemoryScorer.score(category: .temporary, value: "x", explicitBoost: 0.9)
        XCTAssertEqual(score, 0.9, accuracy: 0.01)
    }

    func testExplicitBoostClamped() {
        let over = MemoryScorer.score(category: .preference, value: "x", explicitBoost: 1.5)
        XCTAssertLessThanOrEqual(over, 1.0)
        let under = MemoryScorer.score(category: .preference, value: "x", explicitBoost: -0.2)
        XCTAssertGreaterThanOrEqual(under, 0.0)
    }

    func testDecayReducesImportanceOverTime() {
        let old = MemoryItem(
            key: "old",
            category: .temporary,
            value: "aging",
            createdAt: Date().addingTimeInterval(-10 * 86_400),
            updatedAt: Date().addingTimeInterval(-10 * 86_400),
            importance: 0.8
        )
        let decayed = MemoryScorer.decayedImportance(for: old)
        XCTAssertLessThan(decayed, 0.8)
        XCTAssertGreaterThanOrEqual(decayed, 0.05)
    }

    func testFreshItemBarelyDecays() {
        let fresh = MemoryItem(
            key: "fresh",
            category: .project,
            value: "new",
            importance: 0.7
        )
        let decayed = MemoryScorer.decayedImportance(for: fresh)
        XCTAssertEqual(decayed, 0.7, accuracy: 0.05)
    }

    func testExistingImportanceBlendedOnUpdate() {
        let score = MemoryScorer.score(
            category: .conversation,
            value: "updated note",
            explicitBoost: nil,
            existing: 0.9
        )
        // Should not collapse fully to base; existing influence retained
        XCTAssertGreaterThan(score, 0.4)
        XCTAssertLessThanOrEqual(score, 1.0)
    }
}
