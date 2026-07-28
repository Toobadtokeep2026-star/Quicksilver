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

    func testAutomationBridgeExistsOnCoordinator() {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)
        // AutomationBridge is the canonical surface (AutomationManager removed).
        XCTAssertNotNil(nexus.bridge)
    }
}
