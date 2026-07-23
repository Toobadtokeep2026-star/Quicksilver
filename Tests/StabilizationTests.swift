import XCTest
@testable import Quicksilver

@MainActor
final class StabilizationTests: XCTestCase {
    func testAppConfigurationDefaults() {
        let config = AppConfiguration.shared
        XCTAssertEqual(config.appName, "Quicksilver")
        XCTAssertFalse(config.version.isEmpty)
    }

    func testAppErrorDescriptions() {
        let err = AppError.personaUnavailable("xyz")
        XCTAssertTrue(err.errorDescription?.contains("xyz") == true)
        let unsupported = AppError.unsupportedFeature("test")
        XCTAssertTrue(unsupported.errorDescription?.contains("test") == true)
    }

    func testPersonaRegistryContainsKnownIDs() {
        let registry = PersonaRegistry()
        XCTAssertTrue(registry.contains(id: "quicksilver"))
        XCTAssertTrue(registry.contains(id: "forge"))
        XCTAssertTrue(registry.contains(id: "eternal"))
        XCTAssertFalse(registry.contains(id: "unknown"))
    }

    func testPersonaRegistryRequireThrows() {
        let registry = PersonaRegistry()
        XCTAssertThrowsError(try registry.require(id: "nonexistent"))
    }

    func testPersonaManagerUsesRegistry() async throws {
        let bus = EventBus()
        let logger = LoggerService()
        let manager = PersonaManager(eventBus: bus, logger: logger)
        XCTAssertEqual(manager.activeConfiguration.id, "quicksilver")
        try await manager.switchTo(id: "forge")
        XCTAssertEqual(manager.activeConfiguration.id, "forge")
    }

    func testHealthScoreHealthyNetwork() {
        let calc = HealthScoreCalculator()
        var input = HealthScoreCalculator.Input()
        input.isNetworkConnected = true
        input.batteryLevel = 0.85
        input.thermalState = "nominal"
        input.availableStorageGB = 40
        input.totalStorageGB = 128
        let result = calc.calculate(input)
        XCTAssertGreaterThan(result.network, 80)
        XCTAssertGreaterThan(result.power, 70)
        XCTAssertGreaterThan(result.overall, 70)
    }

    func testHealthScoreDisconnected() {
        let calc = HealthScoreCalculator()
        var input = HealthScoreCalculator.Input()
        input.isNetworkConnected = false
        input.batteryLevel = 0.5
        let result = calc.calculate(input)
        XCTAssertLessThan(result.network, 30)
    }

    func testHealthScoreLowStorage() {
        let calc = HealthScoreCalculator()
        var input = HealthScoreCalculator.Input()
        input.isNetworkConnected = true
        input.availableStorageGB = 1.5
        input.totalStorageGB = 64
        let result = calc.calculate(input)
        XCTAssertLessThan(result.storage, 50)
    }

    func testDeviceMetricsMonitorStartStop() {
        let monitor = DeviceMetricsMonitor()
        monitor.start()
        monitor.stop()
        monitor.stop()
    }

    func testBatteryMonitorStartStop() {
        let monitor = BatteryMonitor()
        monitor.start()
        monitor.stop()
        monitor.stop()
    }

    func testNexusCoordinatorLifecycle() {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)
        XCTAssertFalse(nexus.state.isActive)
        nexus.start()
        XCTAssertTrue(nexus.state.isActive)
        nexus.stop()
        XCTAssertFalse(nexus.state.isActive)
    }
}
