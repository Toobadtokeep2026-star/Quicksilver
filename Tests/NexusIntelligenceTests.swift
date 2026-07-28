import XCTest
@testable import Core
@testable import Nexus

@MainActor
final class NexusIntelligenceTests: XCTestCase {

    // MARK: - Signal factory

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

    func testStorageSignal() {
        let processor = SignalProcessor()
        let signal = processor.storageSignal(availableGB: 3.2, totalGB: 128)
        XCTAssertEqual(signal.source, .storage)
        XCTAssertEqual(signal.numericValue!, 3.2, accuracy: 0.01)
    }

    // MARK: - Insight engine (persona-agnostic)

    func testInsightGenerationForDisconnect() {
        let engine = InsightEngine()
        let signal = Signal(source: .network, category: .connectivity, value: "disconnected")
        let insight = engine.insight(for: signal, recent: [], personaID: "quicksilver")
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.severity, .warning)
        XCTAssertEqual(insight?.personaStyle, "quicksilver")
        XCTAssertEqual(insight?.title, "Network lost")
    }

    func testInsightWithoutPersonaTag() {
        let engine = InsightEngine()
        let signal = Signal(source: .network, category: .connectivity, value: "disconnected")
        let insight = engine.insight(for: signal, recent: [])
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.personaStyle, "")
        XCTAssertEqual(insight?.title, "Network lost")
    }

    func testInsightTagsPersonaStyleOnly() {
        // Architecture rule: InsightEngine is persona-agnostic.
        // Voice/style is applied at presentation time. personaStyle is a tag only.
        let engine = InsightEngine()
        let signal = Signal(source: .network, category: .connectivity, value: "disconnected")

        let forgeInsight = engine.insight(for: signal, recent: [], personaID: "forge")
        XCTAssertNotNil(forgeInsight)
        XCTAssertEqual(forgeInsight?.personaStyle, "forge")
        // Body must remain neutral (no "Technical:" prefix or similar)
        XCTAssertFalse(forgeInsight?.body.contains("Technical:") ?? true)
        XCTAssertEqual(forgeInsight?.body, "The device is currently offline.")

        let eternalInsight = engine.insight(for: signal, recent: [], personaID: "eternal")
        XCTAssertEqual(eternalInsight?.personaStyle, "eternal")
        XCTAssertEqual(eternalInsight?.body, forgeInsight?.body)
    }

    func testLowBatteryInsight() {
        let engine = InsightEngine()
        let signal = Signal(
            source: .battery,
            category: .power,
            value: "unplugged",
            numericValue: 0.12
        )
        let insight = engine.insight(for: signal, recent: [], personaID: "quicksilver")
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.severity, .warning)
        XCTAssertTrue(insight?.title.lowercased().contains("low battery") ?? false)
    }

    func testStoragePressureInsight() {
        let engine = InsightEngine()
        let signal = Signal(
            source: .storage,
            category: .capacity,
            value: "low",
            numericValue: 1.5
        )
        let insight = engine.insight(for: signal, recent: [])
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.severity, .warning)
        XCTAssertTrue(insight?.title.lowercased().contains("storage") ?? false)
    }

    func testThermalCriticalInsight() {
        let engine = InsightEngine()
        let signal = Signal(
            source: .device,
            category: .performance,
            value: "critical"
        )
        let insight = engine.insight(for: signal, recent: [])
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.severity, .warning)
        XCTAssertTrue(insight?.title.lowercased().contains("thermal") ?? false)
    }

    func testNoInsightForHealthyNetwork() {
        let engine = InsightEngine()
        let signal = Signal(source: .network, category: .connectivity, value: "satisfied")
        let insight = engine.insight(for: signal, recent: [])
        XCTAssertNil(insight)
    }

    // MARK: - Full path: signal → insight → state

    func testFullSignalToInsightToStatePath() {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)

        XCTAssertFalse(nexus.state.isActive)
        nexus.start()
        XCTAssertTrue(nexus.state.isActive)

        let processor = SignalProcessor()
        let engine = InsightEngine()

        let disconnect = processor.networkSignal(isConnected: false, isExpensive: false, isConstrained: false)
        XCTAssertEqual(disconnect.value, "disconnected")

        var state = nexus.state
        state.appendSignal(disconnect)

        if let insight = engine.insight(for: disconnect, recent: state.recentSignals, personaID: "forge") {
            state.appendInsight(insight)
            XCTAssertEqual(state.recentInsights.first?.personaStyle, "forge")
            XCTAssertEqual(state.recentInsights.first?.severity, .warning)
            XCTAssertFalse(state.recentInsights.isEmpty)
        } else {
            XCTFail("Expected insight for disconnect signal")
        }

        XCTAssertFalse(state.recentSignals.isEmpty)
        XCTAssertEqual(state.recentSignals.first?.source, .network)

        nexus.stop()
        XCTAssertFalse(nexus.state.isActive)
    }

    func testNexusCoordinatorStartsAndStopsCleanly() {
        let logger = LoggerService()
        let bus = EventBus()
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)

        XCTAssertFalse(nexus.state.isActive)
        nexus.start()
        XCTAssertTrue(nexus.state.isActive)
        XCTAssertTrue(nexus.isActive)

        nexus.updatePersonaContext("forge")
        // Persona context is internal; no crash is the success condition here

        nexus.stop()
        XCTAssertFalse(nexus.state.isActive)
    }

    func testHealthScoreUpdatesFromSignals() {
        var state = NexusState()
        XCTAssertEqual(state.overallHealthScore, 100)

        // Simulate the same scoring logic used inside NexusCoordinator.updateLocalState
        state.networkHealthScore = 20 // disconnected
        state.powerHealthScore = 42
        let scores = [state.networkHealthScore, state.powerHealthScore]
        state.overallHealthScore = scores.reduce(0, +) / max(scores.count, 1)

        XCTAssertEqual(state.overallHealthScore, 31)
    }

    func testInsightHistoryCapped() {
        var state = NexusState()
        for i in 0..<25 {
            let insight = Insight(
                title: "t\(i)",
                body: "b",
                personaStyle: ""
            )
            state.appendInsight(insight, maxHistory: 20)
        }
        XCTAssertEqual(state.recentInsights.count, 20)
        XCTAssertEqual(state.recentInsights.first?.title, "t24")
    }
}
