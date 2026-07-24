import Foundation
import Observation

/// ViewModel for the root dashboard.
/// Owns only the state slices the UI actually renders.
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Published slices

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

    // MARK: - Dependencies

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        refresh()
    }

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
        guard id != activePersonaID else { return }
        container.switchPersona(to: id)
        Task {
            try? await Task.sleep(for: .milliseconds(120))
            refresh()
        }
    }
}
