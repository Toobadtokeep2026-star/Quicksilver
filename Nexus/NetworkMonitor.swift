import Foundation
import Network

/// Network path observer using Network.framework (public, App Store safe).
/// Day One: basic path monitoring. Future: quality metrics, captive portal detection, constrained path handling.
final class NetworkMonitor: @unchecked Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.quicksilver.networkmonitor")
    private var isRunning = false

    private(set) var isConnected: Bool = false
    private(set) var isExpensive: Bool = false
    private(set) var isConstrained: Bool = false

    func start() {
        guard !isRunning else { return }
        isRunning = true

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.isConnected = path.status == .satisfied
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained
            QuicksilverLogger.debug(
                "Network path updated — connected: \(path.status == .satisfied)",
                category: .nexus
            )
        }

        monitor.start(queue: queue)
        QuicksilverLogger.debug("NetworkMonitor started", category: .nexus)
    }

    func stop() {
        guard isRunning else { return }
        monitor.cancel()
        isRunning = false
        QuicksilverLogger.debug("NetworkMonitor stopped", category: .nexus)
    }
}
