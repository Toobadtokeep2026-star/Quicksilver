import Foundation
import Core
#if canImport(UIKit)
import UIKit
#endif

/// Battery perception using only public UIDevice APIs.
/// Token-based observers for clean lifecycle management.
final class BatteryMonitor: BatteryMonitoring, @unchecked Sendable {
    var diagnosticID: String { "battery" }

    private var isRunning = false
    private var levelToken: NSObjectProtocol?
    private var stateToken: NSObjectProtocol?

    private(set) var level: Double = -1
    private(set) var stateDescription: String = "unknown"
    var onChange: ((Double, String) -> Void)?

    func start() {
        guard !isRunning else { return }
        isRunning = true

        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true

        levelToken = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.update() }

        stateToken = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.update() }

        update()
        #endif
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        #if canImport(UIKit)
        if let levelToken {
            NotificationCenter.default.removeObserver(levelToken)
            self.levelToken = nil
        }
        if let stateToken {
            NotificationCenter.default.removeObserver(stateToken)
            self.stateToken = nil
        }
        UIDevice.current.isBatteryMonitoringEnabled = false
        #endif
    }

    deinit {
        stop()
    }

    #if canImport(UIKit)
    private func update() {
        let device = UIDevice.current
        level = Double(device.batteryLevel)
        switch device.batteryState {
        case .charging: stateDescription = "charging"
        case .full: stateDescription = "full"
        case .unplugged: stateDescription = "unplugged"
        @unknown default: stateDescription = "unknown"
        }
        onChange?(level, stateDescription)
    }
    #endif
}
