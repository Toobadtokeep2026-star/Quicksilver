import Foundation
import Core

/// Storage pressure monitor using FileManager (public API only).
/// Samples on a timer; all state mutation and callbacks occur on the main queue.
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

        // Timer must be scheduled on the main run loop.
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isRunning else { return }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
                self?.sample()
            }
        }
    }

    public func stop() {
        isRunning = false
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func sample() {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let free = attrs[.systemFreeSize] as? NSNumber,
               let total = attrs[.systemSize] as? NSNumber {
                let available = free.doubleValue / 1_073_741_824
                let totalGB = total.doubleValue / 1_073_741_824

                let apply = { [weak self] in
                    guard let self else { return }
                    self.availableGB = available
                    self.totalGB = totalGB
                    self.onChange?(available, totalGB)
                }

                if Thread.isMainThread {
                    apply()
                } else {
                    DispatchQueue.main.async(execute: apply)
                }
            }
        } catch {
            // Best-effort; storage sampling must never crash the app.
        }
    }
}
