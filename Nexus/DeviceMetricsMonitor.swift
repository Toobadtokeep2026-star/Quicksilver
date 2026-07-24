import Foundation

final class DeviceMetricsMonitor: DeviceMetricsMonitoring, @unchecked Sendable {
    private var isRunning = false
    private var thermalToken: NSObjectProtocol?
    private var powerToken: NSObjectProtocol?

    private(set) var thermalStateDescription: String = "unknown"
    private(set) var isLowPowerMode = false
    var onChange: ((String, Bool) -> Void)?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        update()

        thermalToken = NotificationCenter.default.addObserver(
            forName: Notification.Name.NSProcessInfoThermalStateDidChange,
            object: nil, queue: .main
        ) { [weak self] _ in self?.update() }

        powerToken = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil, queue: .main
        ) { [weak self] _ in self?.update() }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        if let thermalToken { NotificationCenter.default.removeObserver(thermalToken); self.thermalToken = nil }
        if let powerToken { NotificationCenter.default.removeObserver(powerToken); self.powerToken = nil }
    }

    deinit { stop() }

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
