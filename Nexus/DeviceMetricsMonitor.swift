import Foundation
import Core

public final class DeviceMetricsMonitor: DeviceMetricsMonitoring, @unchecked Sendable {
    public var diagnosticID: String { "device" }

    private var isRunning = false
    private var thermalToken: NSObjectProtocol?
    private var powerToken: NSObjectProtocol?

    public private(set) var thermalStateDescription: String = "unknown"
    public private(set) var isLowPowerMode = false
    public var onChange: ((String, Bool) -> Void)?

    public init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        update()

        thermalToken = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.update() }

        // Correct constant: ProcessInfo has no powerStateDidChangeNotification member.
        // Low-power mode changes are posted as NSProcessInfoPowerStateDidChange.
        powerToken = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.update() }
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false
        if let thermalToken {
            NotificationCenter.default.removeObserver(thermalToken)
            self.thermalToken = nil
        }
        if let powerToken {
            NotificationCenter.default.removeObserver(powerToken)
            self.powerToken = nil
        }
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
