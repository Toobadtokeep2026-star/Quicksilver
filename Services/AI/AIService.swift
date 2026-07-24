import Foundation
import Observation
import Core

@MainActor
@Observable
final class AIService {
    private(set) var isProcessing = false
    private(set) var lastResponse: AIResponse?

    private var provider: AIProvider
    private let eventBus: EventBus
    private let logger: LoggerService
    private let featureFlags: FeatureFlags
    private let promptBuilder = PromptBuilder()
    private let contextAssembler = ContextAssembler()

    static let apiKeyKeychainAccount = "xai.apiKey"

    init(provider: AIProvider? = nil, eventBus: EventBus, logger: LoggerService, featureFlags: FeatureFlags) {
        self.eventBus = eventBus
        self.logger = logger
        self.featureFlags = featureFlags

        if let provider {
            self.provider = provider
        } else {
            self.provider = Self.makeDefaultProvider(featureFlags: featureFlags, logger: logger)
        }
    }

    private static func makeDefaultProvider(featureFlags: FeatureFlags, logger: LoggerService) -> AIProvider {
        if featureFlags.isEnabled("aiServiceEnabled"),
           let key = KeychainStore.string(forKey: apiKeyKeychainAccount),
           !key.isEmpty,
           let grok = GrokAIProvider.make(apiKey: key) {
            logger.info("AI provider selected: Grok (key present)", category: logger.ai)
            return grok
        }
        logger.info("AI provider selected: Mock", category: logger.ai)
        return MockAIProvider()
    }

    func setProvider(_ newProvider: AIProvider) {
        provider = newProvider
        logger.info("AI provider switched to \(newProvider.displayName)", category: logger.ai)
    }

    func configureAPIKey(_ key: String?) {
        if let key, !key.isEmpty {
            KeychainStore.set(key, forKey: Self.apiKeyKeychainAccount)
            if featureFlags.isEnabled("aiServiceEnabled"), let grok = GrokAIProvider.make(apiKey: key) {
                setProvider(grok)
            }
        } else {
            KeychainStore.delete(forKey: Self.apiKeyKeychainAccount)
            setProvider(MockAIProvider())
        }
    }

    var currentProviderID: String { provider.id }
    var currentProviderName: String { provider.displayName }

    // MARK: - Preferred entry point

    /// Persona-aware completion. Views pass user text + optional context fragments only.
    func complete(
        userMessage: String,
        personaSystemPrompt: String,
        preferredTemperature: Double = 0.7,
        maxTokensHint: Int = 1024,
        context: ContextAssembler.Input = .init()
    ) async throws -> AIResponse {
        let assembled = contextAssembler.assemble(context)
        let built = promptBuilder.build(
            personaSystemPrompt: personaSystemPrompt,
            preferredTemperature: preferredTemperature,
            maxTokensHint: maxTokensHint,
            userMessage: userMessage,
            assembledContext: assembled
        )
        return try await execute(
            prompt: built.userPrompt,
            systemPrompt: built.systemPrompt,
            temperature: built.temperature,
            maxTokens: built.maxTokens
        )
    }

    // MARK: - Legacy / low-level

    func complete(prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 1024) async throws -> AIResponse {
        try await execute(prompt: prompt, systemPrompt: systemPrompt, temperature: temperature, maxTokens: maxTokens)
    }

    // MARK: - Internal

    private func execute(prompt: String, systemPrompt: String?, temperature: Double, maxTokens: Int) async throws -> AIResponse {
        guard featureFlags.isEnabled("aiServiceEnabled") || provider.id == "mock" else {
            throw AppError.unsupportedFeature("AI service is currently disabled by feature flag")
        }

        let request = AIRequest(prompt: prompt, systemPrompt: systemPrompt, temperature: temperature, maxTokens: maxTokens)
        isProcessing = true
        await eventBus.publish(.aiRequestStarted(requestID: request.id.uuidString))
        logger.debug("AI request started: \(request.id)", category: logger.ai)
        defer { isProcessing = false }

        do {
            let raw = try await provider.complete(request)
            switch ResponseValidator.validate(raw) {
            case .accept(let response):
                lastResponse = response
                await eventBus.publish(.aiRequestCompleted(requestID: request.id.uuidString))
                logger.info("AI request completed: \(response.id)", category: logger.ai)
                return response
            case .reject(let reason):
                logger.error("AI response rejected: \(reason)", category: logger.ai)
                throw AppError.aiRequestFailed(reason)
            }
        } catch {
            logger.error("AI request failed: \(error.localizedDescription)", category: logger.ai)
            throw error
        }
    }
}
