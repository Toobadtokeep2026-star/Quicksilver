import Foundation
import Network
import Core

public final class NetworkMonitor: NetworkMonitoring, @unchecked Sendable {
    public var diagnosticID: String { "network" }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.quicksilver.nexus.network")
    private var isRunning = false
    public private(set) var isConnected = false
    public private(set) var isExpensive = false
    public private(set) var isConstrained = false
    public var onChange: ((Bool, Bool, Bool) -> Void)?

    public init() {}

    public func start() {
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

    public func stop() {
        guard isRunning else { return }
        monitor.cancel()
        isRunning = false
        monitor.pathUpdateHandler = nil
    }

    deinit { stop() }
}
