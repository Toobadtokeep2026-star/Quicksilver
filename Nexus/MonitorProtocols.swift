import Foundation

/// Protocol surface for the network path monitor.
/// Concrete implementation uses Network.framework (NWPathMonitor).
protocol NetworkMonitoring: AnyObject {
    var isConnected: Bool { get }
    var isExpensive: Bool { get }
    var isConstrained: Bool { get }
    var onChange: ((Bool, Bool, Bool) -> Void)? { get set }

    func start()
    func stop()
}

/// Protocol surface for battery level and state.
protocol BatteryMonitoring: AnyObject {
    var level: Double { get }
    var stateDescription: String { get }
    var onChange: ((Double, String) -> Void)? { get set }

    func start()
    func stop()
}

/// Protocol surface for free / total storage.
protocol StorageMonitoring: AnyObject {
    var availableGB: Double { get }
    var totalGB: Double { get }
    var onChange: ((Double, Double) -> Void)? { get set }

    func start()
    func stop()
}

/// Protocol surface for thermal state and Low Power Mode.
protocol DeviceMetricsMonitoring: AnyObject {
    var thermalStateDescription: String { get }
    var isLowPowerMode: Bool { get }
    var onChange: ((String, Bool) -> Void)? { get set }

    func start()
    func stop()
}
