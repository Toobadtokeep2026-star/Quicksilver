import Foundation
import Network

final class NetworkMonitor: NetworkMonitoring, @unchecked Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.quicksilver.nexus.network")
    private var isRunning = false
    private(set) var isConnected = false
    private(set) var isExpensive = false
    private(set) var isConstrained = false
    var onChange: ((Bool, Bool, Bool) -> Void)?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            self.isConnected = connected
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained
            self.onChange?(connected, path.isExpensive, path.isConstrained)
        }
        monitor.start(queue: queue)
    }

    func stop() {
        guard isRunning else { return }
        monitor.cancel()
        isRunning = false
        monitor.pathUpdateHandler = nil
    }

    deinit { stop() }
}
