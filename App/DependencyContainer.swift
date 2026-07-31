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

        self.personaManager = PersonaManager(
            eventBus: eventBus,
            logger: logger,
            featureFlags: featureFlags
        )

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

        // SideStore first-run: warm memory so Ask / Intents / Home don't wait
        // for MemoryView to open. Failures are logged inside MemoryManager.
        Task { await memoryManager.load() }

        logger.info("DependencyContainer ready — \(configuration.fullVersionString)", category: logger.general)
    }

    var activeConfiguration: PersonaConfiguration {
        personaManager.activeConfiguration
    }

    func switchPersona(to id: String) {
        Task { @MainActor in
            do {
                try await personaManager.switchTo(id: id)
                nexus.updatePersonaContext(id)
            } catch {
                logger.error("Persona switch failed: \(error.localizedDescription)", category: logger.persona)
            }
        }
    }

    func switchPersona(to config: PersonaConfiguration) {
        switchPersona(to: config.id)
    }

    func switchPersonaThrowing(to id: String) async throws {
        try await personaManager.switchTo(id: id)
        nexus.updatePersonaContext(id)
    }
}
