import XCTest
@testable import Core
@testable import Personas
@testable import Nexus
@testable import Memory
@testable import ServicesAI
@testable import QuicksilverIntents

@MainActor
final class IntentDependenciesTests: XCTestCase {

    override func tearDown() {
        IntentDependencies.shared.resetForTesting()
        super.tearDown()
    }

    func testInitiallyNotConfigured() {
        IntentDependencies.shared.resetForTesting()
        XCTAssertFalse(IntentDependencies.shared.isConfigured)
        XCTAssertNil(IntentDependencies.shared.personaManager)
    }

    func testConfigureOnce() {
        let bus = EventBus()
        let logger = LoggerService()
        let flags = FeatureFlags()
        let persona = PersonaManager(eventBus: bus, logger: logger)
        let memory = MemoryManager(store: UserDefaultsMemoryStore(), eventBus: bus, logger: logger)
        let ai = AIService(eventBus: bus, logger: logger, featureFlags: flags)
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)

        IntentDependencies.shared.configure(
            personaManager: persona,
            nexusCoordinator: nexus,
            memoryManager: memory,
            aiService: ai,
            eventBus: bus,
            logger: logger
        )

        XCTAssertTrue(IntentDependencies.shared.isConfigured)
        XCTAssertEqual(IntentDependencies.shared.personaManager?.activeConfiguration.id, "quicksilver")
    }

    func testSecondConfigureIsIgnored() {
        let bus = EventBus()
        let logger = LoggerService()
        let flags = FeatureFlags()
        let persona1 = PersonaManager(eventBus: bus, logger: logger)
        let memory = MemoryManager(store: UserDefaultsMemoryStore(), eventBus: bus, logger: logger)
        let ai = AIService(eventBus: bus, logger: logger, featureFlags: flags)
        let nexus = NexusCoordinator(logger: logger, eventBus: bus)

        IntentDependencies.shared.configure(
            personaManager: persona1,
            nexusCoordinator: nexus,
            memoryManager: memory,
            aiService: ai,
            eventBus: bus,
            logger: logger
        )

        let persona2 = PersonaManager(initial: .forge, eventBus: bus, logger: logger)
        IntentDependencies.shared.configure(
            personaManager: persona2,
            nexusCoordinator: nexus,
            memoryManager: memory,
            aiService: ai,
            eventBus: bus,
            logger: logger
        )

        // Still the first one
        XCTAssertEqual(IntentDependencies.shared.personaManager?.activeConfiguration.id, "quicksilver")
    }
}
