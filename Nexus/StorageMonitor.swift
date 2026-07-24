import Foundation

final class StorageMonitor: StorageMonitoring, @unchecked Sendable {
    private var isRunning = false
    private var timer: Timer?
    private(set) var availableGB: Double = 0
    private(set) var totalGB: Double = 0
    var onChange: ((Double, Double) -> Void)?

    func start() {
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

    func stop() {
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
