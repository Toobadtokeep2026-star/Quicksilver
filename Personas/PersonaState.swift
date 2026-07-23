import Foundation

/// Runtime state of the currently active persona.
struct PersonaState: Sendable, Equatable {
    let configuration: PersonaConfiguration
    var sessionStart: Date
    var interactionCount: Int
    var lastSwitchedAt: Date?

    var id: String { configuration.id }
    var displayName: String { configuration.displayName }

    init(configuration: PersonaConfiguration) {
        self.configuration = configuration
        self.sessionStart = Date()
        self.interactionCount = 0
        self.lastSwitchedAt = nil
    }

    mutating func recordInteraction() {
        interactionCount += 1
    }
}
