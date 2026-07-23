import XCTest
@testable import Core
@testable import Nexus

@MainActor
final class NexusTests: XCTestCase {
    func testNexusStartsAndStopsCleanly() {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)
        XCTAssertFalse(nexus.state.isActive)

        nexus.start()
        XCTAssertTrue(nexus.state.isActive)

        // Idempotent start
        nexus.start()
        XCTAssertTrue(nexus.state.isActive)

        nexus.stop()
        XCTAssertFalse(nexus.state.isActive)
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
