import XCTest
@testable import Core
@testable import Personas

@MainActor
final class PersonaManagerTests: XCTestCase {

    // MARK: - Explicit API

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
        XCTAssertEqual(manager.lastSwitchReason, "explicit override")
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

    func testAutonomyDisabledDoesNotAutoSwitch() async throws {
        let bus = EventBus()
        let logger = LoggerService()
        let flags = FeatureFlags()
        flags.set("personaAutonomy", enabled: false)

        let manager = PersonaManager(
            eventBus: bus,
            logger: logger,
            policy: PersonaDecisionPolicy(minimumDwellSeconds: 0),
            featureFlags: flags
        )

        // Seed a context that would normally prefer Forge
        manager.updateTaskContext(kind: .building)
        // Allow any scheduled Task to run
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(manager.activeConfiguration.id, "quicksilver")
        XCTAssertNil(manager.lastSwitchReason)
    }

    // MARK: - Context-aware Decision Policy

    func testTaskKindBuildingPrefersForge() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let context = PersonaContext(taskKind: .building)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            context: context
        )
        XCTAssertEqual(result?.id, "forge")
    }

    func testQueryIntentReflectivePrefersEternal() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let context = PersonaContext(queryIntent: .reflective)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            context: context
        )
        XCTAssertEqual(result?.id, "eternal")
    }

    func testTaskDescriptionArchitecturePrefersForge() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let context = PersonaContext(taskDescription: "Review the architecture decision")
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            context: context
        )
        XCTAssertEqual(result?.id, "forge")
    }

    func testRecentMemoryHintsPreferEternal() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let context = PersonaContext(recentMemoryHints: ["prior goal: ship core layer"])
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            context: context
        )
        XCTAssertEqual(result?.id, "eternal")
    }

    func testEnvironmentalFallbackStillWorks() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let context = PersonaContext(batteryLevel: 0.12, isLowPower: true)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: nil,
            context: context
        )
        XCTAssertEqual(result?.id, "forge")
    }

    func testDwellTimeStillRespected() {
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 3600)
        let context = PersonaContext(taskKind: .building)
        let result = policy.preferredPersona(
            current: .quicksilver,
            lastSwitchedAt: Date(),
            context: context
        )
        XCTAssertNil(result)
    }

    func testTaskContextBeatsTimeOfDay() {
        // Even at night, an explicit building task should win
        let policy = PersonaDecisionPolicy(minimumDwellSeconds: 0)
        let context = PersonaContext(
            taskKind: .building,
            timePeriod: .night
        )
        let result = policy.preferredPersona(
            current: .eternal,
            lastSwitchedAt: nil,
            context: context
        )
        XCTAssertEqual(result?.id, "forge")
    }
}
