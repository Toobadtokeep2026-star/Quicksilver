import Foundation
import Core
#if canImport(UIKit)
import UIKit
#endif

/// Battery perception using only public UIDevice APIs.
/// Token-based observers for clean lifecycle management.
///
/// Isolation note: UIDevice + NotificationCenter require main-queue delivery.
/// The class is marked `@unchecked Sendable` because the underlying Apple APIs
/// are not Sendable; all mutable state is only touched on the main queue.
public final class BatteryMonitor: BatteryMonitoring, @unchecked Sendable {
    public var diagnosticID: String { "battery" }

    private var isRunning = false
    private var levelToken: NSObjectProtocol?
    private var stateToken: NSObjectProtocol?

    public private(set) var level: Double = -1
    public private(set) var stateDescription: String = "unknown"
    public var onChange: ((Double, String) -> Void)?

    public init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        #if canImport(UIKit)
        if Thread.isMainThread {
            MainActor.assumeIsolated { enableAndObserve() }
        } else {
            Task { @MainActor in self.enableAndObserve() }
        }
        #endif
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false

        #if canImport(UIKit)
        if Thread.isMainThread {
            MainActor.assumeIsolated { cleanupObservers() }
        } else {
            Task { @MainActor in self.cleanupObservers() }
        }
        #endif
    }

    deinit {
        #if canImport(UIKit)
        if let levelToken { NotificationCenter.default.removeObserver(levelToken) }
        if let stateToken { NotificationCenter.default.removeObserver(stateToken) }
        #endif
    }

    #if canImport(UIKit)
    @MainActor
    private func enableAndObserve() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        levelToken = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }

        stateToken = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }

        update()
    }

    @MainActor
    private func cleanupObservers() {
        if let levelToken {
            NotificationCenter.default.removeObserver(levelToken)
            self.levelToken = nil
        }
        if let stateToken {
            NotificationCenter.default.removeObserver(stateToken)
            self.stateToken = nil
        }
        UIDevice.current.isBatteryMonitoringEnabled = false
    }

    @MainActor
    private func update() {
        let device = UIDevice.current
        level = Double(device.batteryLevel)
        switch device.batteryState {
        case .charging: stateDescription = "charging"
        case .full: stateDescription = "full"
        case .unplugged: stateDescription = "unplugged"
        case .unknown: stateDescription = "unknown"
        @unknown default: stateDescription = "unknown"
        }
        onChange?(level, stateDescription)
    }
    #endif
}
