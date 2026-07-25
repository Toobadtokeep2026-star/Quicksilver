import Foundation
import Core

public final class StorageMonitor: StorageMonitoring, @unchecked Sendable {
    public var diagnosticID: String { "storage" }

    private var isRunning = false
    private var timer: Timer?
    public private(set) var availableGB: Double = 0
    public private(set) var totalGB: Double = 0
    public var onChange: ((Double, Double) -> Void)?

    public init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        sample()
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isRunning else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
                self?.sample()
            }
        }
    }

    public func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    deinit { stop() }

    private func sample() {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let free = attrs[.systemFreeSize] as? NSNumber,
               let total = attrs[.systemSize] as? NSNumber {
                availableGB = free.doubleValue / 1_073_741_824
                totalGB = total.doubleValue / 1_073_741_824
                onChange?(availableGB, totalGB)
            }
        } catch { }
    }
}
