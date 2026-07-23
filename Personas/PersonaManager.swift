import Foundation

/// Owns persona lifecycle and switching.
/// Uses PersonaRegistry as the single source of truth.
@MainActor
final class PersonaManager: ObservableObject {
    @Published private(set) var state: PersonaState

    private let registry: PersonaRegistry
    private let eventBus: EventBus
    private let logger: LoggerService

    init(
        initialID: String = "quicksilver",
        registry: PersonaRegistry = PersonaRegistry(),
        eventBus: EventBus,
        logger: LoggerService
    ) {
        self.registry = registry
        self.eventBus = eventBus
        self.logger = logger

        let initialConfig = registry.configuration(for: initialID) ?? .quicksilver
        self.state = PersonaState(configuration: initialConfig)
    }

    var activeConfiguration: PersonaConfiguration {
        state.configuration
    }

    var availableConfigurations: [PersonaConfiguration] {
        registry.all
    }

    func switchTo(id: String) async throws {
        let config = try registry.require(id: id)
        guard config.id != state.id else { return }

        var newState = PersonaState(configuration: config)
        newState.lastSwitchedAt = Date()
        state = newState

        logger.info("Switched persona to \(config.displayName)", category: logger.persona)
        await eventBus.publish(.personaDidChange(personaID: config.id))
    }

    func switchTo(_ config: PersonaConfiguration) async throws {
        try await switchTo(id: config.id)
    }

    func recordInteraction() {
        state.recordInteraction()
    }
}
