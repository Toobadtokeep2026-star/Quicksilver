import Foundation

/// Polls free / total storage on a low-frequency timer (battery-friendly).
final class StorageMonitor: @unchecked Sendable {
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

    deinit {
        stop()
    }

    private func sample() {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let free = attrs[.systemFreeSize] as? NSNumber,
               let total = attrs[.systemSize] as? NSNumber {
                availableGB = free.doubleValue / 1_073_741_824
                totalGB = total.doubleValue / 1_073_741_824
                onChange?(availableGB, totalGB)
            }
        } catch {
            // Intentionally quiet — storage sampling is best-effort
        }
    }
}
