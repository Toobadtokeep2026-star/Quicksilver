import Foundation
import Core

/// Decides which persona should be active given current context.
/// Priority: task/intent first, then continuity, then environmental fallbacks.
/// Pure and side-effect free so it stays easy to test and later replace with a learned policy.
public struct PersonaDecisionPolicy: Sendable {

    /// Minimum time a persona must stay active before an autonomous switch is allowed.
    public let minimumDwellSeconds: TimeInterval

    public init(minimumDwellSeconds: TimeInterval = 15 * 60) {
        self.minimumDwellSeconds = minimumDwellSeconds
    }

    /// Evaluate the preferred persona.
    /// Returns nil when no change is recommended.
    public func preferredPersona(
        current: PersonaConfiguration,
        lastSwitchedAt: Date?,
        context: PersonaContext
    ) -> PersonaConfiguration? {

        // Respect dwell time – avoid thrashing
        if let last = lastSwitchedAt,
           Date().timeIntervalSince(last) < minimumDwellSeconds {
            return nil
        }

        // 1. Strongest signal: explicit task kind
        if let kind = context.taskKind {
            switch kind {
            case .building, .debugging:
                return prefer(.forge, over: current)
            case .exploring, .creative:
                return prefer(.quicksilver, over: current)
            case .reflecting:
                return prefer(.eternal, over: current)
            case .communicating:
                // Default to adaptive unless more context arrives
                return prefer(.quicksilver, over: current)
            case .unknown:
                break
            }
        }

        // 2. Query intent (when a concrete request is in flight)
        if let intent = context.queryIntent {
            switch intent {
            case .preciseTechnical, .diagnostic:
                return prefer(.forge, over: current)
            case .strategic, .creative:
                return prefer(.quicksilver, over: current)
            case .reflective:
                return prefer(.eternal, over: current)
            case .unknown:
                break
            }
        }

        // 3. Lightweight heuristics on free-text task description
        if let task = context.taskDescription?.lowercased() {
            if containsAny(task, ["architect", "implement", "refactor", "debug", "fix", "fix", "precision", "structure"]) {
                return prefer(.forge, over: current)
            }
            if containsAny(task, ["idea", "brainstorm", "explore", "what if", "creative", "strategy", "option"]) {
                return prefer(.quicksilver, over: current)
            }
            if containsAny(task, ["reflect", "review", "remember", "history", "long-term", "continuity", "pattern"]) {
                return prefer(.eternal, over: current)
            }
        }

        // 4. Continuity signal from recent memory
        if !context.recentMemoryHints.isEmpty {
            // Presence of substantial recent memory tilts toward Eternal
            // (protects identity and prior context)
            return prefer(.eternal, over: current)
        }

        // 5. Environmental fallbacks (kept for when no richer context exists)

        // Focus name
        if let focus = context.focusName?.lowercased() {
            if containsAny(focus, ["work", "deep", "focus"]) {
                return prefer(.forge, over: current)
            }
            if containsAny(focus, ["sleep", "rest", "wind"]) {
                return prefer(.eternal, over: current)
            }
            if containsAny(focus, ["personal", "creative"]) {
                return prefer(.quicksilver, over: current)
            }
        }

        // Device pressure → calm, efficient persona
        if context.isLowPower || (context.batteryLevel ?? 1.0) < 0.20 {
            return prefer(.forge, over: current)
        }
        if let thermal = context.thermalState?.lowercased(),
           containsAny(thermal, ["serious", "critical"]) {
            return prefer(.forge, over: current)
        }

        // Time of day as last resort
        switch context.timePeriod {
        case .earlyMorning, .morning:
            return prefer(.forge, over: current)
        case .afternoon:
            return prefer(.quicksilver, over: current)
        case .evening, .night:
            return prefer(.eternal, over: current)
        case .none:
            break
        }

        return nil
    }

    // MARK: - Helpers

    private func prefer(_ candidate: PersonaConfiguration, over current: PersonaConfiguration) -> PersonaConfiguration? {
        candidate.id == current.id ? nil : candidate
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
