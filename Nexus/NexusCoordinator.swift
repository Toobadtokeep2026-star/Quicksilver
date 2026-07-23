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

    private func handleNetwork(connected: Bool, expensive: Bool, constrained: Bool) {
        let signal = processor.networkSignal(isConnected: connected, isExpensive: expensive, isConstrained: constrained)
        ingest(signal)
        state.networkStatus = signal.value
        state.isNetworkExpensive = expensive
        state.isNetworkConstrained = constrained
        state.networkHealthScore = connected ? (constrained || expensive ? 70 : 95) : 20
        recalculateOverallHealth()
    }

    private func handleBattery(level: Double, description: String) {
        let signal = processor.batterySignal(level: level, stateDescription: description)
        ingest(signal)
        state.batteryLevel = level >= 0 ? level : nil
        state.batteryState = description
        if level >= 0 { state.powerHealthScore = Int(level * 100) }
        recalculateOverallHealth()
    }

    private func handleStorage(available: Double, total: Double) {
        let signal = processor.storageSignal(availableGB: available, totalGB: total)
        ingest(signal)
        state.availableStorageGB = available
        state.totalStorageGB = total
    }

    private func handleDevice(thermal: String, lowPower: Bool) {
        let signal = processor.deviceSignal(thermal: thermal, lowPower: lowPower)
        ingest(signal)
        state.thermalState = thermal
        state.lowPowerMode = lowPower
    }

    private func ingest(_ signal: Signal) {
        state.appendSignal(signal)
        let event = DiagnosticEvent(signalID: signal.id, title: "\(signal.source.rawValue.capitalized) update", detail: signal.value, severity: .info, source: signal.source)
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
}
