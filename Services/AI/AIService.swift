import Foundation
import Combine
import Core

@MainActor
final class AIService: ObservableObject {
    @Published private(set) var isProcessing = false
    @Published private(set) var lastResponse: AIResponse?

    private var provider: AIProvider
    private let eventBus: EventBus
    private let logger: LoggerService
    private let featureFlags: FeatureFlags

    init(provider: AIProvider = MockAIProvider(), eventBus: EventBus, logger: LoggerService, featureFlags: FeatureFlags) {
        self.provider = provider
        self.eventBus = eventBus
        self.logger = logger
        self.featureFlags = featureFlags
    }

    func setProvider(_ newProvider: AIProvider) {
        provider = newProvider
        logger.info("AI provider switched to \(newProvider.displayName)", category: logger.ai)
    }

    func complete(prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 1024) async throws -> AIResponse {
        guard featureFlags.isEnabled("aiServiceEnabled") || provider.id == "mock" else {
            throw AppError.unsupportedFeature("AI service is currently disabled by feature flag")
        }

        let request = AIRequest(prompt: prompt, systemPrompt: systemPrompt, temperature: temperature, maxTokens: maxTokens)
        isProcessing = true
        await eventBus.publish(.aiRequestStarted(requestID: request.id.uuidString))
        logger.debug("AI request started: \(request.id)", category: logger.ai)

        defer { isProcessing = false }

        do {
            let response = try await provider.complete(request)
            lastResponse = response
            await eventBus.publish(.aiRequestCompleted(requestID: request.id.uuidString))
            logger.info("AI request completed: \(response.id)", category: logger.ai)
            return response
        } catch {
            logger.error("AI request failed: \(error.localizedDescription)", category: logger.ai)
            throw error
        }
    }
}
