import Foundation
import Core

/// Thermal and Low Power Mode monitor using ProcessInfo (public API only).
/// Token-based observers; all delivery on the main queue.
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

        let startOnMain = { [weak self] in
            guard let self else { return }
            self.update()

            self.thermalToken = NotificationCenter.default.addObserver(
                forName: ProcessInfo.thermalStateDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in self?.update() }

            // Correct constant: NSProcessInfoPowerStateDidChange
            self.powerToken = NotificationCenter.default.addObserver(
                forName: .NSProcessInfoPowerStateDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in self?.update() }
        }

        if Thread.isMainThread {
            startOnMain()
        } else {
            DispatchQueue.main.async(execute: startOnMain)
        }
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false

        let cleanup = { [weak self] in
            guard let self else { return }
            if let thermalToken = self.thermalToken {
                NotificationCenter.default.removeObserver(thermalToken)
                self.thermalToken = nil
            }
            if let powerToken = self.powerToken {
                NotificationCenter.default.removeObserver(powerToken)
                self.powerToken = nil
            }
        }

        if Thread.isMainThread {
            cleanup()
        } else {
            DispatchQueue.main.async(execute: cleanup)
        }
    }

    deinit {
        if let thermalToken { NotificationCenter.default.removeObserver(thermalToken) }
        if let powerToken { NotificationCenter.default.removeObserver(powerToken) }
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
