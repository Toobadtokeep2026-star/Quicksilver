import Foundation
import Network
import Core

/// Network path monitor using NWPathMonitor (public API only).
///
/// Isolation note: NWPathMonitor delivers on a private queue. We hop to main
/// before mutating state or invoking onChange so callers can safely assume
/// main-thread delivery. `@unchecked Sendable` is required because the
/// underlying Network framework types are not Sendable.
///
/// Lifecycle: `NWPathMonitor` is single-use after `cancel()`. `start()` always
/// constructs a fresh monitor so stop → start cycles (backgrounding, Nexus restart) work.
public final class NetworkMonitor: NetworkMonitoring, @unchecked Sendable {
    public var diagnosticID: String { "network" }

    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "com.quicksilver.nexus.network", qos: .utility)
    private var isRunning = false

    public private(set) var isConnected = false
    public private(set) var isExpensive = false
    public private(set) var isConstrained = false
    public var onChange: ((Bool, Bool, Bool) -> Void)?

    public init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        let pathMonitor = NWPathMonitor()
        monitor = pathMonitor

        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            let expensive = path.isExpensive
            let constrained = path.isConstrained

            // Deliver on main so NexusCoordinator (MainActor) sees consistent state.
            DispatchQueue.main.async {
                self.isConnected = connected
                self.isExpensive = expensive
                self.isConstrained = constrained
                self.onChange?(connected, expensive, constrained)
            }
        }
        pathMonitor.start(queue: queue)
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false
        monitor?.cancel()
        monitor?.pathUpdateHandler = nil
        monitor = nil
    }

    deinit {
        monitor?.cancel()
    }
}
