import Foundation
import Core

/// Single ingress for all monitoring signals.
/// Monitors feed here; the pipeline normalizes, lightly rate-limits,
/// publishes a unified EventBus event, and maps high-value signals
/// onto the existing autonomy events.
@MainActor
final class SignalPipeline {

    private let eventBus: EventBus
    private let logger: LoggerService

    /// Minimum interval between identical source+value emissions.
    private let dedupeInterval: TimeInterval
    private var lastEmitted: [String: (value: String, at: Date)] = [:]

    init(eventBus: EventBus, logger: LoggerService, dedupeInterval: TimeInterval = 2.0) {
        self.eventBus = eventBus
        self.logger = logger
        self.dedupeInterval = dedupeInterval
    }

    /// Primary entry point used by all monitors.
    func ingest(_ signal: Signal) {
        let key = signal.source.rawValue

        // Light dedupe / rate-limit for noisy sources
        if let previous = lastEmitted[key],
           previous.value == signal.value,
           Date().timeIntervalSince(previous.at) < dedupeInterval {
            return
        }
        lastEmitted[key] = (signal.value, Date())

        Task {
            // Unified stream for dashboard, insights, AI health analysis, etc.
            await eventBus.publish(
                .signalReceived(
                    source: signal.source.rawValue,
                    value: signal.value,
                    numericValue: signal.numericValue
                )
            )

            // Map onto existing autonomy events so PersonaManager keeps working
            await mapToAutonomyEvents(signal)
        }
    }

    // MARK: - Autonomy mapping

    private func mapToAutonomyEvents(_ signal: Signal) async {
        switch signal.source {
        case .battery:
            let level = signal.numericValue ?? -1
            let isLow = (level >= 0 && level < 0.20) || signal.value.lowercased().contains("low")
            await eventBus.publish(.batteryPressureChanged(level: level, isLowPower: isLow))

        case .device:
            await eventBus.publish(.thermalPressureChanged(state: signal.value))
            if signal.metadata["lowPower"] == "true" || signal.value.lowercased().contains("low power") {
                await eventBus.publish(.batteryPressureChanged(level: signal.numericValue ?? 0.15, isLowPower: true))
            }

        case .network:
            let connected = signal.value != "disconnected"
            let constrained = signal.value == "constrained" || signal.value == "expensive"
            await eventBus.publish(.networkConditionChanged(isConnected: connected, isConstrained: constrained))

        default:
            break
        }
    }
}
