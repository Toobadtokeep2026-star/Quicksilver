import Foundation

/// DEPRECATED — Do not use.
/// Real thermal and low-power sensing is implemented in `DeviceMetricsMonitor`.
/// This placeholder remains only to avoid breaking any residual references.
/// Scheduled for removal once the last reference is confirmed gone.
@available(*, deprecated, message: "Use DeviceMetricsMonitor instead")
final class SystemMonitor: @unchecked Sendable {
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func currentMemoryFootprintMB() -> Double { 0 }
    func thermalStateDescription() -> String { "unknown" }
}
