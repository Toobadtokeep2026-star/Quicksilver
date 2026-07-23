import Foundation

/// Core identity contract for all Quicksilver personas.
/// Kept for backward compatibility with Day One UI.
/// New code should prefer PersonaConfiguration + PersonaManager.
protocol Persona: Sendable, Identifiable {
    var id: String { get }
    var name: String { get }
    var shortDescription: String { get }
    var systemPrompt: String { get }
    var accentColorName: String { get }
}

extension Persona {
    var debugDescription: String {
        "\(name) (\(id))"
    }
}
