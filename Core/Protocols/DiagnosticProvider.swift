import Foundation

/// Contract for any source of device or environmental diagnostics.
/// Nexus monitors conform to this (or to more specific sub-protocols).
public protocol DiagnosticProvider: AnyObject {
    /// Human-readable identifier (e.g. "battery", "network").
    var diagnosticID: String { get }

    /// Start observing. Must be idempotent.
    func start()

    /// Stop observing and release resources. Must be idempotent.
    func stop()
}
