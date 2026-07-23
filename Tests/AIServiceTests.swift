import XCTest
@testable import Quicksilver

@MainActor
final class AIServiceTests: XCTestCase {
    func testMockProviderReturnsResponse() async throws {
        let bus = EventBus()
        let logger = LoggerService()
        let flags = FeatureFlags()
        let service = AIService(
            provider: MockAIProvider(),
            eventBus: bus,
            logger: logger,
            featureFlags: flags
        )

        let response = try await service.complete(prompt: "Hello Quicksilver")
        XCTAssertFalse(response.content.isEmpty)
        XCTAssertEqual(response.finishReason, .stop)
        XCTAssertNotNil(service.lastResponse)
    }

    func testDependencyContainerWiresAIService() {
        let container = DependencyContainer()
        XCTAssertNotNil(container.aiService)
        XCTAssertNotNil(container.personaManager)
        XCTAssertNotNil(container.memoryManager)
        XCTAssertNotNil(container.featureFlags)
        XCTAssertNotNil(container.eventBus)
    }
}
