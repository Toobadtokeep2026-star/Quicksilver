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

        // Make the autonomous core + AI reachable by App Intents / Shortcuts / Siri
        IntentDependencies.shared.configure(
            personaManager: personaManager,
            nexusCoordinator: nexus,
            memoryManager: memoryManager,
            aiService: aiService,
            eventBus: eventBus,
            logger: logger
        )

        Task {
            self.nexus.updatePersonaContext(self.personaManager.activeConfiguration.id)
            self.nexus.start()
        }
    }

    var activePersona: any Persona {
        switch personaManager.activeConfiguration.id {
        case "forge": return ForgePersona()
        case "eternal": return EternalPersona()
        default: return QuicksilverPersona()
        }
    }

    func switchPersona(to persona: any Persona) {
        Task {
            try? await personaManager.switchTo(id: persona.id)
            nexus.updatePersonaContext(persona.id)
            // No manual objectWillChange needed — @Observable tracks the graph
        }
    }
}
