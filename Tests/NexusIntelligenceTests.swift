import XCTest
@testable import Quicksilver

@MainActor
final class NexusIntelligenceTests: XCTestCase {
    func testSignalCreation() {
        let processor = SignalProcessor()
        let signal = processor.networkSignal(isConnected: true, isExpensive: false, isConstrained: false)
        XCTAssertEqual(signal.source, .network)
        XCTAssertEqual(signal.value, "satisfied")
        XCTAssertEqual(signal.confidence, 0.95, accuracy: 0.01)
    }

    func testBatterySignal() {
        let processor = SignalProcessor()
        let signal = processor.batterySignal(level: 0.42, stateDescription: "unplugged")
        XCTAssertEqual(signal.source, .battery)
        XCTAssertEqual(signal.numericValue!, 0.42, accuracy: 0.01)
    }

    func testInsightGenerationForDisconnect() {
        let engine = InsightEngine()
        let signal = Signal(source: .network, category: .connectivity, value: "disconnected")
        let insight = engine.insight(for: signal, recent: [], personaID: "quicksilver")
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.severity, .warning)
    }

    func testInsightPersonaStyling() {
        let engine = InsightEngine()
        let signal = Signal(source: .network, category: .connectivity, value: "disconnected")
        let forgeInsight = engine.insight(for: signal, recent: [], personaID: "forge")
        XCTAssertTrue(forgeInsight?.body.contains("Technical:") == true)
    }

    func testNexusCoordinatorStarts() {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)
        XCTAssertFalse(nexus.state.isActive)
        nexus.start()
        XCTAssertTrue(nexus.state.isActive)
        nexus.stop()
        XCTAssertFalse(nexus.state.isActive)
    }

    func testDependencyContainerWiresNexus() {
        let container = DependencyContainer()
        XCTAssertNotNil(container.nexus)
        XCTAssertNotNil(container.nexus.state)
    }
}
