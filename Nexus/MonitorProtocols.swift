import Foundation
import Core

/// Network path monitor contract. Also a DiagnosticProvider.
public protocol NetworkMonitoring: DiagnosticProvider {
    var isConnected: Bool { get }
    var isExpensive: Bool { get }
    var isConstrained: Bool { get }
    var onChange: ((Bool, Bool, Bool) -> Void)? { get set }
}

/// Battery monitor contract. Also a DiagnosticProvider.
public protocol BatteryMonitoring: DiagnosticProvider {
    var level: Double { get }
    var stateDescription: String { get }
    var onChange: ((Double, String) -> Void)? { get set }
}

/// Storage monitor contract. Also a DiagnosticProvider.
public protocol StorageMonitoring: DiagnosticProvider {
    var availableGB: Double { get }
    var totalGB: Double { get }
    var onChange: ((Double, Double) -> Void)? { get set }
}

/// Thermal / Low Power monitor contract. Also a DiagnosticProvider.
public protocol DeviceMetricsMonitoring: DiagnosticProvider {
    var thermalStateDescription: String { get }
    var isLowPowerMode: Bool { get }
    var onChange: ((String, Bool) -> Void)? { get set }
}
