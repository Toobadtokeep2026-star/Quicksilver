import Foundation

/// Contract for persona selection and behavioral influence.
/// Implementations live in the Personas module.
public protocol PersonaEngine: AnyObject {
    /// Currently active persona identifier.
    var activePersonaID: String { get }

    /// Switch to a different persona by id. Throws if unavailable.
    func switchTo(id: String) async throws

    /// Record that an interaction occurred (used for dwell / autonomy policies).
    func recordInteraction()
}
