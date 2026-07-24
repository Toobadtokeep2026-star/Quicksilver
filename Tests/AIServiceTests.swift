import XCTest
@testable import Core
@testable import ServicesAI

@MainActor
final class AIServiceTests: XCTestCase {

    func testMockProviderReturnsResponse() async throws {
        let bus = EventBus()
        let logger = LoggerService()
        let flags = FeatureFlags()
        let service = AIService(provider: MockAIProvider(), eventBus: bus, logger: logger, featureFlags: flags)
        let response = try await service.complete(prompt: "Hello Quicksilver")
        XCTAssertFalse(response.content.isEmpty)
        XCTAssertEqual(response.finishReason, .stop)
    }

    func testFeatureFlagBlocksRealProvider() async {
        let bus = EventBus()
        let logger = LoggerService()
        let flags = FeatureFlags()
        // Default is aiServiceEnabled = false
        let service = AIService(eventBus: bus, logger: logger, featureFlags: flags)

        // Provider will be Mock because flag is off / no key, so this should still succeed
        do {
            _ = try await service.complete(prompt: "test")
        } catch {
            XCTFail("Mock path should not throw when flag is off")
        }
    }

    func testGrokMakeFactoryRejectsEmptyKey() {
        let provider = GrokAIProvider.make(apiKey: "")
        XCTAssertNil(provider)
    }

    func testGrokMakeFactoryAcceptsValidKey() {
        let provider = GrokAIProvider.make(apiKey: "xai-test-key")
        XCTAssertNotNil(provider)
        XCTAssertEqual(provider?.id, "grok")
        XCTAssertTrue(provider?.isAvailable == true)
    }
}
