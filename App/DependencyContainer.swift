import Foundation
import SwiftUI
import Observation
import Core
import Personas
import Memory
import ServicesAI
import Nexus
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

        let memoryStore: MemoryStore
        if let swiftDataStore = try? SwiftDataMemoryStore() {
            memoryStore = swiftDataStore
            logger.info("Memory backend: SwiftData", category: logger.memory)
        } else {
            memoryStore = UserDefaultsMemoryStore()
            logger.info("Memory backend: UserDefaults (SwiftData unavailable)", category: logger.memory)
        }
        self.memoryManager = MemoryManager(store: memoryStore, eventBus: eventBus, logger: logger)

        self.aiService = AIService(eventBus: eventBus, logger: logger, featureFlags: featureFlags)

        self.nexus = NexusCoordinator(logger: logger, eventBus: eventBus)

        IntentDependencies.shared.configure(
            personaManager: personaManager,
            nexusCoordinator: nexus,
            memoryManager: memoryManager,
            aiService: aiService,
            eventBus: eventBus,
            logger: logger
        )

        nexus.updatePersonaContext(personaManager.activeConfiguration.id)
        nexus.start()
    }

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
