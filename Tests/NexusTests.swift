import XCTest
@testable import Quicksilver

@MainActor
final class NexusTests: XCTestCase {
    func testNexusStartsAndStopsCleanly() {
        let nexus = NexusCoordinator()
        XCTAssertFalse(nexus.isActive)

        nexus.start()
        XCTAssertTrue(nexus.isActive)

        // Idempotent start
        nexus.start()
        XCTAssertTrue(nexus.isActive)

        nexus.stop()
        XCTAssertFalse(nexus.isActive)
    }

    func testAutomationManagerThrowsUnsupported() {
        let manager = AutomationManager()
        manager.configure()

        XCTAssertThrowsError(try manager.trigger(named: "test")) { error in
            guard let appError = error as? AppError else {
                return XCTFail("Expected AppError")
            }
            if case .unsupportedFeature = appError {
                // expected
            } else {
                XCTFail("Expected unsupportedFeature")
            }
        }
    }
}
