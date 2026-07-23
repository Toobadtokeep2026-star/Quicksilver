import Foundation
#if canImport(UIKit)
import UIKit
#endif

final class BatteryMonitor: @unchecked Sendable {
    private var isRunning = false
    private(set) var level: Double = -1
    private(set) var stateDescription: String = "unknown"
    var onChange: ((Double, String) -> Void)?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryChanged), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryChanged), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        update()
        #endif
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        #endif
    }

    #if canImport(UIKit)
    @objc private func batteryChanged() { update() }
    private func update() {
        let device = UIDevice.current
        level = Double(device.batteryLevel)
        switch device.batteryState {
        case .charging: stateDescription = "charging"
        case .full: stateDescription = "full"
        case .unplugged: stateDescription = "unplugged"
        default: stateDescription = "unknown"
        }
        onChange?(level, stateDescription)
    }
    #endif
}
