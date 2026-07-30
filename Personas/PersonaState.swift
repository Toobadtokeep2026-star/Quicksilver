import Foundation

/// Runtime state of the currently active persona.
public struct PersonaState: Sendable, Equatable {
    public let configuration: PersonaConfiguration
    public var sessionStart: Date
    public var interactionCount: Int
    public var lastSwitchedAt: Date?
    /// Human-readable reason for the most recent switch (explicit or autonomous).
    public var lastSwitchReason: String?

    public var id: String { configuration.id }
    public var displayName: String { configuration.displayName }

    public init(configuration: PersonaConfiguration) {
        self.configuration = configuration
        self.sessionStart = Date()
        self.interactionCount = 0
        self.lastSwitchedAt = nil
        self.lastSwitchReason = nil
    }

    public mutating func recordInteraction() {
        interactionCount += 1
    }
}
