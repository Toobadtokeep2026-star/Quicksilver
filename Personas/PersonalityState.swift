import Foundation

/// Runtime behavioral dimensions that shape Mercury's expression.
/// These are not static traits — they fluctuate with context, interaction, and persona bias.
/// Personality is a system, not just prompt text.
public struct PersonalityState: Sendable, Equatable {

    // MARK: - Core Dimensions (0.0 ... 1.0)

    public var confidence: Double = 0.65
    public var curiosity: Double = 0.70
    public var humor: Double = 0.55
    public var mischief: Double = 0.40
    public var focus: Double = 0.60
    public var initiative: Double = 0.50
    public var skepticism: Double = 0.55
    public var patience: Double = 0.60
    public var loyalty: Double = 0.75

    public init() {}

    // MARK: - Persona Bias

    /// Apply strong directional bias based on active persona.
    public mutating func applyPersonaBias(personaID: String) {
        switch personaID.lowercased() {
        case "forge":
            confidence = 0.80
            curiosity = 0.45
            humor = 0.25
            mischief = 0.10
            focus = 0.90
            initiative = 0.55
            skepticism = 0.70
            patience = 0.65
            loyalty = 0.70
        case "eternal":
            confidence = 0.70
            curiosity = 0.55
            humor = 0.30
            mischief = 0.05
            focus = 0.75
            initiative = 0.40
            skepticism = 0.50
            patience = 0.95
            loyalty = 0.90
        case "quicksilver":
            fallthrough
        default:
            confidence = 0.70
            curiosity = 0.80
            humor = 0.75
            mischief = 0.60
            focus = 0.55
            initiative = 0.65
            skepticism = 0.60
            patience = 0.45
            loyalty = 0.70
        }
    }

    // MARK: - Dynamic Adjustment

    public mutating func increase(_ dimension: Dimension, by amount: Double = 0.05) {
        switch dimension {
        case .confidence: confidence = clamp(confidence + amount)
        case .curiosity: curiosity = clamp(curiosity + amount)
        case .humor: humor = clamp(humor + amount)
        case .mischief: mischief = clamp(mischief + amount)
        case .focus: focus = clamp(focus + amount)
        case .initiative: initiative = clamp(initiative + amount)
        case .skepticism: skepticism = clamp(skepticism + amount)
        case .patience: patience = clamp(patience + amount)
        case .loyalty: loyalty = clamp(loyalty + amount)
        }
    }

    public mutating func decrease(_ dimension: Dimension, by amount: Double = 0.05) {
        increase(dimension, by: -amount)
    }

    public mutating func noteInteraction() {
        // Interaction slightly raises confidence and lowers patience if rapid
        increase(.confidence, by: 0.02)
        decrease(.patience, by: 0.01)
    }

    public mutating func noteInsight() {
        increase(.curiosity, by: 0.03)
        increase(.initiative, by: 0.02)
    }

    public mutating func adjustFor(intent: QueryIntent, kind: TaskKind) {
        switch intent {
        case .preciseTechnical:
            increase(.focus, by: 0.08)
            increase(.skepticism, by: 0.05)
            decrease(.mischief, by: 0.06)
            decrease(.humor, by: 0.04)
        case .reflective:
            increase(.patience, by: 0.07)
            increase(.loyalty, by: 0.03)
            decrease(.mischief, by: 0.05)
        case .creative:
            increase(.curiosity, by: 0.08)
            increase(.mischief, by: 0.05)
            increase(.humor, by: 0.04)
        case .diagnostic:
            increase(.skepticism, by: 0.07)
            increase(.focus, by: 0.05)
            decrease(.humor, by: 0.03)
        case .strategic:
            increase(.initiative, by: 0.04)
            increase(.confidence, by: 0.03)
        }

        switch kind {
        case .building:
            increase(.focus, by: 0.05)
        case .debugging:
            increase(.skepticism, by: 0.06)
        case .reflecting:
            increase(.patience, by: 0.05)
        case .exploring:
            increase(.curiosity, by: 0.05)
        }
    }

    // MARK: - Expression Helpers

    /// Compact bias string injected into system prompts.
    public func promptBias() -> String {
        var parts: [String] = []

        if humor > 0.65 { parts.append("lean into dry wit") }
        if mischief > 0.55 { parts.append("allow controlled trickster energy") }
        if skepticism > 0.65 { parts.append("challenge weak assumptions") }
        if patience < 0.40 { parts.append("be direct; low tolerance for vagueness") }
        if focus > 0.75 { parts.append("prioritize precision and structure") }
        if curiosity > 0.75 { parts.append("probe interesting angles") }
        if confidence > 0.75 { parts.append("speak with quiet authority") }

        return parts.joined(separator: "; ")
    }

    /// Light post-processing color (kept subtle — real personality lives in the model + bias).
    public func colorResponse(_ text: String, personaID: String) -> String {
        // For now we return the text largely unchanged.
        // Future: mild stylistic prefixes or confidence markers based on state.
        // Keeping the model as the primary voice prevents brittle string hacks.
        return text
    }

    // MARK: - Types

    public enum Dimension: String, CaseIterable, Sendable {
        case confidence, curiosity, humor, mischief, focus
        case initiative, skepticism, patience, loyalty
    }

    private func clamp(_ value: Double) -> Double {
        min(1.0, max(0.0, value))
    }
}
