import Foundation
import Observation

@MainActor
@Observable
final class DiagnosticsViewModel {
    private(set) var isActive: Bool = false
    private(set) var overallHealth: Int = 100
    private(set) var insights: [Insight] = []
    private(set) var recentSignals: [Signal] = []
    private(set) var networkStatus: String = "—"
    private(set) var batteryText: String = "—"
    private(set) var thermal: String = "—"
    private(set) var lowPower: Bool = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        refresh()
    }

    func refresh() {
        let state = container.nexus.state
        isActive = state.isActive
        overallHealth = state.overallHealthScore
        insights = Array(state.recentInsights.prefix(12))
        recentSignals = Array(state.recentSignals.prefix(20))
        networkStatus = state.networkStatus.capitalized
        batteryText = state.batteryLevel.map { "\(Int($0 * 100))% (\(state.batteryState))" } ?? "—"
        thermal = state.thermalState.capitalized
        lowPower = state.lowPowerMode
    }
}
