import Foundation
import Observation

/// ViewModel for the root dashboard.
/// Owns only the state slices the UI actually renders.
/// Keeps ContentView free of direct container / Nexus / PersonaManager reach.
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Published slices

    private(set) var personaDisplayName: String = ""
    private(set) var personaDescription: String = ""
    private(set) var isNexusActive: Bool = false
    private(set) var overallHealthScore: Int = 100
    private(set) var lowPowerMode: Bool = false
    private(set) var batteryLevelText: String = "—"
    private(set) var batteryState: String = "unknown"
    private(set) var networkStatus: String = "unknown"
    private(set) var networkSubtitle: String = "OK"
    private(set) var thermalState: String = "unknown"
    private(set) var latestInsight: Insight?

    // MARK: - Dependencies (retained, not published)

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        refresh()
    }

    /// Pull the latest values from the live container.
    /// Called on appear and can be driven by Observation of the container later.
    func refresh() {
        let config = container.activeConfiguration
        personaDisplayName = config.displayName
        personaDescription = config.shortDescription

        let state = container.nexus.state
        isNexusActive = state.isActive
        overallHealthScore = state.overallHealthScore
        lowPowerMode = state.lowPowerMode

        batteryLevelText = state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "—"
        batteryState = state.batteryState

        networkStatus = state.networkStatus.capitalized
        if state.isNetworkExpensive {
            networkSubtitle = "Expensive"
        } else if state.isNetworkConstrained {
            networkSubtitle = "Constrained"
        } else {
            networkSubtitle = "OK"
        }

        thermalState = state.thermalState.capitalized
        latestInsight = state.recentInsights.first
    }

    func switchPersona(to id: String) {
        container.switchPersona(to: id)
        // Refresh after a short delay to pick up the change (policy may be async)
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            refresh()
        }
    }
}
