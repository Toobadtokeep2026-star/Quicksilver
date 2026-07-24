import Foundation
import Core
import Personas
import Nexus
import Memory
import ServicesAI

/// Process-wide dependency registry for App Intents.
///
/// App Intents are instantiated by the system and cannot receive constructor injection.
/// This is the minimal, controlled process-level surface required for Shortcuts / Siri.
///
/// Rules:
/// - Configured exactly once at app launch by DependencyContainer.
/// - All properties are read-only after configuration.
/// - Intents must check `isConfigured` (or the individual optionals) before use.
@MainActor
public final class IntentDependencies {
    public static let shared = IntentDependencies()

    public private(set) var personaManager: PersonaManager?
    public private(set) var nexusCoordinator: NexusCoordinator?
    public private(set) var memoryManager: MemoryManager?
    public private(set) var aiService: AIService?
    public private(set) var eventBus: EventBus?
    public private(set) var logger: LoggerService?

    public var isConfigured: Bool {
        personaManager != nil && nexusCoordinator != nil && aiService != nil
    }

    private init() {}

    /// Single write path. Idempotent after the first successful configuration.
    public func configure(
        personaManager: PersonaManager,
        nexusCoordinator: NexusCoordinator,
        memoryManager: MemoryManager,
        aiService: AIService,
        eventBus: EventBus,
        logger: LoggerService
    ) {
        // Only accept the first configuration. Subsequent calls are ignored to prevent
        // accidental mutation from tests or late re-entry.
        guard !isConfigured else { return }

        self.personaManager = personaManager
        self.nexusCoordinator = nexusCoordinator
        self.memoryManager = memoryManager
        self.aiService = aiService
        self.eventBus = eventBus
        self.logger = logger
    }

    /// Test / reset support. Not used in production.
    func resetForTesting() {
        personaManager = nil
        nexusCoordinator = nil
        memoryManager = nil
        aiService = nil
        eventBus = nil
        logger = nil
    }
}
