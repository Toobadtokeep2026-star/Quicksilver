import Foundation

/// The experiential chambers of the Sanctum.
/// Owned by Core so Brain, UI, and Intents can share the type without boundary violations.
public enum SanctumChamber: String, Sendable, Equatable, CaseIterable {
    case sanctum
    case forge
    case eternal

    public var displayName: String {
        switch self {
        case .sanctum: return "Sanctum"
        case .forge: return "Forge"
        case .eternal: return "Eternal"
        }
    }

    /// Relative intensity for ambient particles / mercury sheen (0...1).
    public var ambientIntensity: Double {
        switch self {
        case .sanctum: return 0.45
        case .forge: return 0.82
        case .eternal: return 0.58
        }
    }
}
