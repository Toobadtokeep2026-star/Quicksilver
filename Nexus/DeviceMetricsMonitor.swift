import Foundation

/// Device-level signals using only public ProcessInfo.
/// Correctly retains and removes block-based NotificationCenter observers.
final class DeviceMetricsMonitor: @unchecked Sendable {
    private var isRunning = false
    private var thermalObserver: NSObjectProtocol?
    private var powerObserver: NSObjectProtocol?

    private(set) var thermalStateDescription: String = "unknown"
    private(set) var isLowPowerMode = false

    var onChange: ((String, Bool) -> Void)?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        update()

        thermalObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.NSProcessInfoThermalStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.update()
        }

        powerObserver = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.update()
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        if let token = thermalObserver {
            NotificationCenter.default.removeObserver(token)
            thermalObserver = nil
        }
        if let token = powerObserver {
            NotificationCenter.default.removeObserver(token)
            powerObserver = nil
        }
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

    deinit {
        stop()
    }
}
