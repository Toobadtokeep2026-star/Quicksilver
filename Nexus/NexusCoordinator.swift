import Foundation

/// Central coordinator for the Nexus subsystem.
/// Owns the monitors and automation surface.
/// Day One: lightweight lifecycle management only.
/// Future: event bus, health aggregation, Shortcuts triggers, background refresh.
@MainActor
final class NexusCoordinator: ObservableObject {
    let systemMonitor: SystemMonitor
    let networkMonitor: NetworkMonitor
    let automationManager: AutomationManager

    @Published private(set) var isActive: Bool = false

    init(
        systemMonitor: SystemMonitor = SystemMonitor(),
        networkMonitor: NetworkMonitor = NetworkMonitor(),
        automationManager: AutomationManager = AutomationManager()
    ) {
        self.systemMonitor = systemMonitor
        self.networkMonitor = networkMonitor
        self.automationManager = automationManager
    }

    /// Start monitoring subsystems. Safe to call multiple times.
    func start() {
        guard !isActive else { return }
        QuicksilverLogger.info("Nexus starting", category: .nexus)
        systemMonitor.start()
        networkMonitor.start()
        isActive = true
    }

    /// Stop monitoring. Call on backgrounding or low-power paths if needed.
    func stop() {
        guard isActive else { return }
        systemMonitor.stop()
        networkMonitor.stop()
        isActive = false
        QuicksilverLogger.info("Nexus stopped", category: .nexus)
    }
}
