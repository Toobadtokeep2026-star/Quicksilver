import Foundation
import SwiftUI

/// Central composition root for Quicksilver.
/// Owns the lifetime of all major services and exposes them to the UI layer.
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Core
    let environment: AppEnvironment
    let configuration: AppConfiguration
    let featureFlags: FeatureFlags
    let logger: LoggerService
    let eventBus: EventBus

    // MARK: - Personas
    let personaManager: PersonaManager

    // MARK: - Memory
    let memoryManager: MemoryManager

    // MARK: - AI
    let aiService: AIService

    // MARK: - Nexus
    let nexus: NexusCoordinator

    // MARK: - Init
    init(
        environment: AppEnvironment = .current,
        configuration: AppConfiguration = .shared
    ) {
        self.environment = environment
        self.configuration = configuration
        self.featureFlags = FeatureFlags()
        self.logger = LoggerService()
        self.eventBus = EventBus()

        self.personaManager = PersonaManager(
            eventBus: eventBus,
            logger: logger
        )

        let memoryStore = UserDefaultsMemoryStore()
        self.memoryManager = MemoryManager(
            store: memoryStore,
            eventBus: eventBus,
            logger: logger
        )

        self.aiService = AIService(
            eventBus: eventBus,
            logger: logger,
            featureFlags: featureFlags
        )

        self.nexus = NexusCoordinator()
    }

    /// Convenience for existing UI that still reads activePersona.
    /// Bridge to the old Persona protocol for Day One UI compatibility.
    /// Will be removed once UI is updated to use PersonaManager directly.
    var activePersona: any Persona {
        switch personaManager.activeConfiguration.id {
        case "forge":
            return ForgePersona()
        case "eternal":
            return EternalPersona()
        default:
            return QuicksilverPersona()
        }
    }

    func switchPersona(to persona: any Persona) {
        Task {
            try? await personaManager.switchTo(id: persona.id)
            objectWillChange.send()
        }
    }
}
