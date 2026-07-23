import Foundation
import Core

/// Decides which persona should be active given current system context.
/// Kept pure and side-effect free so it is trivial to unit test and later replace
/// with a more sophisticated (or learned) policy.
struct PersonaDecisionPolicy: Sendable {

    /// Minimum time a persona must stay active before an autonomous switch is allowed.
    let minimumDwellSeconds: TimeInterval

    init(minimumDwellSeconds: TimeInterval = 15 * 60) {
        self.minimumDwellSeconds = minimumDwellSeconds
    }

    /// Evaluate the preferred persona given the latest signals.
    /// Returns nil when no change is recommended.
    func preferredPersona(
        current: PersonaConfiguration,
        lastSwitchedAt: Date?,
        focusName: String?,
        timePeriod: EventBus.TimePeriod?,
        batteryLevel: Double?,
        isLowPower: Bool,
        thermalState: String?
    ) -> PersonaConfiguration? {

        // Respect dwell time – avoid thrashing
        if let last = lastSwitchedAt,
           Date().timeIntervalSince(last) < minimumDwellSeconds {
            return nil
        }

        // 1. Explicit Focus mappings (highest priority)
        if let focus = focusName?.lowercased() {
            if focus.contains("work") || focus.contains("deep") || focus.contains("focus") {
                return .forge
            }
            if focus.contains("sleep") || focus.contains("rest") || focus.contains("wind") {
                return .eternal
            }
            if focus.contains("personal") || focus.contains("creative") {
                return .quicksilver
            }
        }

        // 2. Battery / thermal pressure → prefer the calm, efficient persona
        if isLowPower || (batteryLevel ?? 1.0) < 0.20 {
            return .forge
        }
        if let thermal = thermalState?.lowercased(),
           thermal.contains("serious") || thermal.contains("critical") {
            return .forge
        }

        // 3. Time-of-day heuristics
        switch timePeriod {
        case .earlyMorning, .morning:
            // Building / structured work
            return current.id == "forge" ? nil : .forge
        case .afternoon:
            // Adaptive / exploratory
            return current.id == "quicksilver" ? nil : .quicksilver
        case .evening, .night:
            // Continuity / reflection
            return current.id == "eternal" ? nil : .eternal
        case .none:
            break
        }

        return nil
    }
}
