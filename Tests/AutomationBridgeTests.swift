import XCTest
@testable import Core
@testable import Nexus

@MainActor
final class AutomationBridgeTests: XCTestCase {

    func testBridgeStartsUnconfigured() {
        let bridge = AutomationBridge()
        XCTAssertFalse(bridge.isConfigured)
        XCTAssertThrowsError(try bridge.reportNetworkStatus())
    }

    func testConfigureWithoutNexusStillAllowsBasicCalls() throws {
        let bridge = AutomationBridge()
        bridge.configure()
        XCTAssertTrue(bridge.isConfigured)

        let status = try bridge.reportNetworkStatus()
        XCTAssertTrue(status.contains("unknown") || status.contains("Nexus not attached"))
    }

    func testFullDiagnosticPathWithLiveNexus() throws {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)
        nexus.start()

        let bridge = nexus.bridge
        XCTAssertTrue(bridge.isConfigured)

        let full = try bridge.triggerDiagnostic(named: "full")
        XCTAssertFalse(full.isEmpty)
        XCTAssertTrue(full.contains("Network") || full.lowercased().contains("unknown") || full.contains("|"))

        let health = try bridge.triggerDiagnostic(named: "health")
        XCTAssertTrue(health.contains("Health") || health.contains("unknown"))

        nexus.stop()
    }

    func testUnsupportedDiagnosticThrows() {
        let bridge = AutomationBridge()
        bridge.configure()
        XCTAssertThrowsError(try bridge.triggerDiagnostic(named: "teleport"))
    }

    func testAvailableCapabilities() {
        let bridge = AutomationBridge()
        XCTAssertTrue(bridge.availableCapabilities.contains(.reportNetworkStatus))
        XCTAssertTrue(bridge.availableCapabilities.contains(.reportBatteryStatus))
        XCTAssertTrue(bridge.availableCapabilities.contains(.runDiagnostic))
    }
}
