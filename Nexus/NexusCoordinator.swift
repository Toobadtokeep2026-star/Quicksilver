import Foundation
import Combine
import Core

@MainActor
final class NexusCoordinator: ObservableObject {
    @Published private(set) var state = NexusState()

    private let networkMonitor: NetworkMonitor
    private let batteryMonitor: BatteryMonitor
    private let storageMonitor: StorageMonitor
    private let deviceMonitor: DeviceMetricsMonitor
    private let processor: SignalProcessor
    private let insightEngine: InsightEngine
    private let automationBridge: AutomationBridge
    private let pipeline: SignalPipeline
    private let logger: LoggerService
    private let eventBus: EventBus
    private var currentPersonaID: String = "quicksilver"
    private var isRunning = false

    init(
        networkMonitor: NetworkMonitor = NetworkMonitor(),
        batteryMonitor: BatteryMonitor = BatteryMonitor(),
        storageMonitor: StorageMonitor = StorageMonitor(),
        deviceMonitor: DeviceMetricsMonitor = DeviceMetricsMonitor(),
        processor: SignalProcessor = SignalProcessor(),
        insightEngine: InsightEngine = InsightEngine(),
        automationBridge: AutomationBridge = AutomationBridge(),
        logger: LoggerService,
        eventBus: EventBus
    ) {
        self.networkMonitor = networkMonitor
        self.batteryMonitor = batteryMonitor
        self.storageMonitor = storageMonitor
        self.deviceMonitor = deviceMonitor
        self.processor = processor
        self.insightEngine = insightEngine
        self.automationBridge = automationBridge
        self.logger = logger
        self.eventBus = eventBus
        self.pipeline = SignalPipeline(eventBus: eventBus, logger: logger)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        state.isActive = true
        logger.info("Nexus starting", category: logger.nexus)
        automationBridge.configure()

        networkMonitor.onChange = { [weak self] c, e, k in Task { @MainActor in self?.handleNetwork(connected: c, expensive: e, constrained: k) } }
        batteryMonitor.onChange = { [weak self] l, d in Task { @MainActor in self?.handleBattery(level: l, description: d) } }
        storageMonitor.onChange = { [weak self] a, t in Task { @MainActor in self?.handleStorage(available: a, total: t) } }
        deviceMonitor.onChange = { [weak self] t, lp in Task { @MainActor in self?.handleDevice(thermal: t, lowPower: lp) } }

        networkMonitor.start()
        batteryMonitor.start()
        storageMonitor.start()
        deviceMonitor.start()

        Task {
            await publishCurrentTimeContext()
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        state.isActive = false
        networkMonitor.stop()
        batteryMonitor.stop()
        storageMonitor.stop()
        deviceMonitor.stop()
        logger.info("Nexus stopped", category: logger.nexus)
    }

    func updatePersonaContext(_ personaID: String) {
        currentPersonaID = personaID
    }

    // MARK: - Monitor handlers → pipeline

    private func handleNetwork(connected: Bool, expensive: Bool, constrained: Bool) {
        let signal = processor.networkSignal(isConnected: connected, isExpensive: expensive, isConstrained: constrained)
        pipeline.ingest(signal)
        updateLocalState(from: signal, expensive: expensive, constrained: constrained)
    }

    private func handleBattery(level: Double, description: String) {
        let signal = processor.batterySignal(level: level, stateDescription: description)
        pipeline.ingest(signal)
        updateLocalState(from: signal)
    }

    private func handleStorage(available: Double, total: Double) {
        let signal = processor.storageSignal(availableGB: available, totalGB: total)
        pipeline.ingest(signal)
        state.availableStorageGB = available
        state.totalStorageGB = total
    }

    private func handleDevice(thermal: String, lowPower: Bool) {
        var signal = processor.deviceSignal(thermal: thermal, lowPower: lowPower)
        // Ensure metadata carries low-power for the pipeline mapping
        if lowPower {
            signal = Signal(
                id: signal.id,
                source: signal.source,
                category: signal.category,
                timestamp: signal.timestamp,
                value: signal.value,
                numericValue: signal.numericValue,
                confidence: signal.confidence,
                metadata: signal.metadata.merging(["lowPower": "true"]) { _, new in new }
            )
        }
        pipeline.ingest(signal)
        state.thermalState = thermal
        state.lowPowerMode = lowPower
    }

    // MARK: - Local state + insights

    private func updateLocalState(from signal: Signal, expensive: Bool = false, constrained: Bool = false) {
        state.appendSignal(signal)

        switch signal.source {
        case .network:
            state.networkStatus = signal.value
            state.isNetworkExpensive = expensive
            state.isNetworkConstrained = constrained
            state.networkHealthScore = signal.value != "disconnected"
                ? (constrained || expensive ? 70 : 95)
                : 20
        case .battery:
            if let level = signal.numericValue, level >= 0 {
                state.batteryLevel = level
                state.powerHealthScore = Int(level * 100)
            }
            state.batteryState = signal.value
        default:
            break
        }

        recalculateOverallHealth()

        let event = DiagnosticEvent(
            signalID: signal.id,
            title: "\(signal.source.rawValue.capitalized) update",
            detail: signal.value,
            severity: .info,
            source: signal.source
        )
        state.appendEvent(event)

        if let insight = insightEngine.insight(for: signal, recent: state.recentSignals, personaID: currentPersonaID) {
            state.appendInsight(insight)
            logger.info("Insight: \(insight.title)", category: logger.nexus)
        }
    }

    private func recalculateOverallHealth() {
        let scores = [state.networkHealthScore, state.powerHealthScore]
        state.overallHealthScore = scores.reduce(0, +) / max(scores.count, 1)
    }

    private func publishCurrentTimeContext() async {
        let hour = Calendar.current.component(.hour, from: Date())
        let period: EventBus.TimePeriod
        switch hour {
        case 5..<8:   period = .earlyMorning
        case 8..<12:  period = .morning
        case 12..<17: period = .afternoon
        case 17..<21: period = .evening
        default:      period = .night
        }
        await eventBus.publish(.timeContextDidChange(period: period))
    }
}
