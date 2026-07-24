import Foundation
import SwiftUI
import Observation
import QuicksilverIntents

@MainActor
@Observable
final class DependencyContainer {
    let environment: AppEnvironment
    let configuration: AppConfiguration
    let featureFlags: FeatureFlags
    let logger: LoggerService
    let eventBus: EventBus
    let personaManager: PersonaManager
    let memoryManager: MemoryManager
    let aiService: AIService
    let nexus: NexusCoordinator

    init(environment: AppEnvironment = .current, configuration: AppConfiguration = .shared) {
        self.environment = environment
        self.configuration = configuration
        self.featureFlags = FeatureFlags()
        self.logger = LoggerService()
        self.eventBus = EventBus()

        self.personaManager = PersonaManager(eventBus: eventBus, logger: logger)

        let memoryStore = UserDefaultsMemoryStore()
        self.memoryManager = MemoryManager(store: memoryStore, eventBus: eventBus, logger: logger)

        self.aiService = AIService(eventBus: eventBus, logger: logger, featureFlags: featureFlags)

        self.nexus = NexusCoordinator(logger: logger, eventBus: eventBus)

        // Make the autonomous core + AI reachable by App Intents / Shortcuts / Siri.
        // (Singleton remains for now — tracked as next P1 issue.)
        IntentDependencies.shared.configure(
            personaManager: personaManager,
            nexusCoordinator: nexus,
            memoryManager: memoryManager,
            aiService: aiService,
            eventBus: eventBus,
            logger: logger
        )

        // Start Nexus on the main actor after all dependencies are wired.
        // No unstructured Task — deterministic lifecycle, easy to stop later.
        nexus.updatePersonaContext(personaManager.activeConfiguration.id)
        nexus.start()
    }

    /// Current active configuration — single source of truth.
    var activeConfiguration: PersonaConfiguration {
        personaManager.activeConfiguration
    }

    func switchPersona(to id: String) {
        Task {
            try? await personaManager.switchTo(id: id)
            nexus.updatePersonaContext(id)
        }
    }

    func switchPersona(to config: PersonaConfiguration) {
        switchPersona(to: config.id)
    }
}
