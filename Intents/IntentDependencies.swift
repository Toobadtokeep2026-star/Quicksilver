import Foundation
import Core
import Personas
import Nexus
import Memory

/// Shared dependencies for App Intents.
/// The app sets these up once at launch. Intents then read them safely.
@MainActor
public final class IntentDependencies {
    public static let shared = IntentDependencies()

    public var personaManager: PersonaManager?
    public var nexusCoordinator: NexusCoordinator?
    public var memoryManager: MemoryManager?
    public var eventBus: EventBus?
    public var logger: LoggerService?

    private init() {}

    public func configure(
        personaManager: PersonaManager,
        nexusCoordinator: NexusCoordinator,
        memoryManager: MemoryManager,
        eventBus: EventBus,
        logger: LoggerService
    ) {
        self.personaManager = personaManager
        self.nexusCoordinator = nexusCoordinator
        self.memoryManager = memoryManager
        self.eventBus = eventBus
        self.logger = logger
    }
}
