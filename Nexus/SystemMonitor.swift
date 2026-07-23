import Foundation

/// Device and process health observer.
/// Day One: placeholder surface only.
/// Future integrations (all public APIs):
/// - ProcessInfo for thermal/memory pressure
/// - MetricKit for diagnostic payloads (iOS 13+)
/// - OSLog / Logger for structured events
/// - UIDevice for battery state (with care for privacy)
/// Do NOT use private APIs or sysctl hacks that break App Store review.
final class SystemMonitor: @unchecked Sendable {
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        QuicksilverLogger.debug("SystemMonitor started (placeholder)", category: .nexus)
    }

    func stop() {
        isRunning = false
        QuicksilverLogger.debug("SystemMonitor stopped", category: .nexus)
    }

    /// Placeholder. Real implementation will sample ProcessInfo.processInfo.physicalMemory etc.
    func currentMemoryFootprintMB() -> Double {
        // Intentionally returns 0 until real sampling is added.
        // Using task_info / mach would be possible but is more complex and needs careful entitlement review.
        return 0
    }

    /// Thermal state placeholder. Real path: ProcessInfo.processInfo.thermalState
    func thermalStateDescription() -> String {
        "unknown (Day One placeholder)"
    }
}
