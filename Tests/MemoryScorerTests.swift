import XCTest
@testable import Memory

final class MemoryScorerTests: XCTestCase {

    func testSystemCategoryIsHigh() {
        let score = MemoryScorer.score(category: .system, value: "core config")
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }

    func testTemporaryIsLow() {
        let score = MemoryScorer.score(category: .temporary, value: "scratch")
        XCTAssertLessThan(score, 0.4)
    }

    func testExplicitBoostWins() {
        let score = MemoryScorer.score(category: .temporary, value: "x", explicitBoost: 0.95)
        XCTAssertEqual(score, 0.95, accuracy: 0.001)
    }

    func testUpdatePreservesExistingWhenNoBoost() {
        let score = MemoryScorer.score(
            category: .conversation,
            value: "update",
            existing: 0.8
        )
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }
}
