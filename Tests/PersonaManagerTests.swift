import XCTest
@testable import Core
@testable import Personas

@MainActor
final class PersonaManagerTests: XCTestCase {

    // MARK: - Existing explicit API

    func testInitialPersonaIsQuicksilver() {
        let bus = EventBus()
        let logger = LoggerService()
        let manager = PersonaManager(eventBus: bus, logger: logger)
        XCTAssertEqual(manager.activeConfiguration.id, "quicksilver")
    }

    func testSwitchToForge() async throws {
        let bus = EventBus()
        let logger = LoggerService()
        let manager = PersonaManager(eventBus: bus, logger: logger)
        try await manager.switchTo(id: "forge")
        XCTAssertEqual(manager.activeConfiguration.id, "forge")
    }

    func testSwitchToUnknownThrows() async {
        let bus = EventBus()
        let logger = LoggerService()
        let manager = PersonaManager(eventBus: bus, logger: logger)
        do {
            try await manager.switchTo(id: "nonexistent")
            XCTFail("Expected error")
        } catch { }
    }

    // MARK: - Decision Policy (pure)

    func testPolicyPrefersForgeOnLowBattery() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            focusName: nil,
            timePeriod: nil,
            batteryLevel: 0.12,
            isLowPower: true,
            thermalState: nil
        )
        XCTAssertEqual(result?.id, "forge")
    }

    func testPolicyPrefersEternalAtNight() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            focusName: nil,
            timePeriod: .night,
            batteryLevel: 0.8,
            isLowPower: false,
            thermalState: nil
        )
        XCTAssertEqual(result?.id, "eternal")
    }

    func testPolicyRespectsDwellTime() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 60 * 60) // 1 hour
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: Date(), // just switched
            focusName: "Work",
            timePeriod: .morning,
            batteryLevel: 0.9,
            isLowPower: false,
            thermalState: nil
        )
        XCTAssertNil(result, "Should not switch while inside dwell window")
    }

    func testPolicyFocusWorkMapsToForge() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            focusName: "Deep Work",
            timePeriod: nil,
            batteryLevel: 0.9,
            isLowPower: false,
            thermalState: nil
        )
        XCTAssertEqual(result?.id, "forge")
    }
}
