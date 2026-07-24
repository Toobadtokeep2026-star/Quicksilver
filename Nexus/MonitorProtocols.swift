import Foundation

protocol NetworkMonitoring: AnyObject {
    var isConnected: Bool { get }
    var isExpensive: Bool { get }
    var isConstrained: Bool { get }
    var onChange: ((Bool, Bool, Bool) -> Void)? { get set }
    func start()
    func stop()
}

protocol BatteryMonitoring: AnyObject {
    var level: Double { get }
    var stateDescription: String { get }
    var onChange: ((Double, String) -> Void)? { get set }
    func start()
    func stop()
}

protocol StorageMonitoring: AnyObject {
    var availableGB: Double { get }
    var totalGB: Double { get }
    var onChange: ((Double, Double) -> Void)? { get set }
    func start()
    func stop()
}

protocol DeviceMetricsMonitoring: AnyObject {
    var thermalStateDescription: String { get }
    var isLowPowerMode: Bool { get }
    var onChange: ((String, Bool) -> Void)? { get set }
    func start()
    func stop()
}
