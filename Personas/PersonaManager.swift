import Foundation

/// Owns persona lifecycle and switching.
/// Publishes changes via EventBus so other modules stay decoupled.
@MainActor
final class PersonaManager: ObservableObject {
    @Published private(set) var state: PersonaState

    private let eventBus: EventBus
    private let logger: LoggerService
    private let available: [PersonaConfiguration]

    init(
        initial: PersonaConfiguration = .quicksilver,
        available: [PersonaConfiguration] = PersonaConfiguration.all,
        eventBus: EventBus,
        logger: LoggerService
    ) {
        self.state = PersonaState(configuration: initial)
        self.available = available
        self.eventBus = eventBus
        self.logger = logger
    }

    var activeConfiguration: PersonaConfiguration {
        state.configuration
    }

    var availableConfigurations: [PersonaConfiguration] {
        available
    }

    func switchTo(id: String) async throws {
        guard let config = available.first(where: { $0.id == id }) else {
            throw AppError.personaUnavailable(id)
        }
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
