import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var personaDisplayName: String = ""
    private(set) var personaDescription: String = ""
    private(set) var activePersonaID: String = "quicksilver"
    private(set) var availablePersonas: [PersonaConfiguration] = PersonaConfiguration.all

    private(set) var isNexusActive: Bool = false
    private(set) var overallHealthScore: Int = 100
    private(set) var lowPowerMode: Bool = false
    private(set) var batteryLevelText: String = "—"
    private(set) var batteryState: String = "unknown"
    private(set) var networkStatus: String = "unknown"
    private(set) var networkSubtitle: String = "OK"
    private(set) var thermalState: String = "unknown"
    private(set) var latestInsight: Insight?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        refresh()
    }

    /// Pulls the current truth from DependencyContainer (persona + live NexusState).
    /// Call on appear, after persona switch, and whenever the user forces a refresh.
    func refresh() {
        let config = container.activeConfiguration
        personaDisplayName = config.displayName
        personaDescription = config.shortDescription
        activePersonaID = config.id
        availablePersonas = container.personaManager.availableConfigurations

        let state = container.nexus.state
        isNexusActive = state.isActive
        overallHealthScore = state.overallHealthScore
        lowPowerMode = state.lowPowerMode
        batteryLevelText = state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "—"
        batteryState = state.batteryState
        networkStatus = state.networkStatus.capitalized
        networkSubtitle = state.isNetworkExpensive ? "Expensive" : (state.isNetworkConstrained ? "Constrained" : "OK")
        thermalState = state.thermalState.capitalized
        latestInsight = state.recentInsights.first
    }

    func switchPersona(to id: String) {
        guard id != activePersonaID else { return }
        container.switchPersona(to: id)
        // Brief delay so the persona switch + Nexus context update can settle
        Task {
            try? await Task.sleep(for: .milliseconds(120))
            refresh()
        }
    }
}
