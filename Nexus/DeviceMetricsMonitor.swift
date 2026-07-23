import Foundation

final class DeviceMetricsMonitor: @unchecked Sendable {
    private var isRunning = false
    private(set) var thermalStateDescription: String = "unknown"
    private(set) var isLowPowerMode = false
    var onChange: ((String, Bool) -> Void)?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        update()
        NotificationCenter.default.addObserver(forName: Notification.Name.NSProcessInfoThermalStateDidChange, object: nil, queue: .main) { [weak self] _ in self?.update() }
        NotificationCenter.default.addObserver(forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main) { [weak self] _ in self?.update() }
    }

    func stop() {
        isRunning = false
        NotificationCenter.default.removeObserver(self)
    }

    private func update() {
        let info = ProcessInfo.processInfo
        switch info.thermalState {
        case .nominal: thermalStateDescription = "nominal"
        case .fair: thermalStateDescription = "fair"
        case .serious: thermalStateDescription = "serious"
        case .critical: thermalStateDescription = "critical"
        @unknown default: thermalStateDescription = "unknown"
        }
        isLowPowerMode = info.isLowPowerModeEnabled
        onChange?(thermalStateDescription, isLowPowerMode)
    }
}
