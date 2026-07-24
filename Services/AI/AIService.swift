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

    /// Preferred key under which the xAI / Grok API key is stored in Keychain.
    static let apiKeyKeychainAccount = "xai.apiKey"

    init(provider: AIProvider? = nil, eventBus: EventBus, logger: LoggerService, featureFlags: FeatureFlags) {
        self.eventBus = eventBus
        self.logger = logger
        self.featureFlags = featureFlags

        if let provider {
            self.provider = provider
        } else {
            // Auto-select: real provider only when a key is present and the feature is enabled.
            self.provider = Self.makeDefaultProvider(featureFlags: featureFlags, logger: logger)
        }
    }

    private static func makeDefaultProvider(featureFlags: FeatureFlags, logger: LoggerService) -> AIProvider {
        if featureFlags.isEnabled("aiServiceEnabled"),
           let key = KeychainStore.string(forKey: apiKeyKeychainAccount),
           !key.isEmpty {
            logger.info("AI provider selected: Grok (key present)", category: logger.ai)
            return GrokAIProvider(apiKey: key)
        }
        logger.info("AI provider selected: Mock", category: logger.ai)
        return MockAIProvider()
    }

    func setProvider(_ newProvider: AIProvider) {
        provider = newProvider
        logger.info("AI provider switched to \(newProvider.displayName)", category: logger.ai)
    }

    /// Persist an API key and switch to the real provider if the feature flag allows it.
    func configureAPIKey(_ key: String?) {
        if let key, !key.isEmpty {
            KeychainStore.set(key, forKey: Self.apiKeyKeychainAccount)
            if featureFlags.isEnabled("aiServiceEnabled") {
                setProvider(GrokAIProvider(apiKey: key))
            }
        } else {
            KeychainStore.delete(forKey: Self.apiKeyKeychainAccount)
            setProvider(MockAIProvider())
        }
    }

    var currentProviderID: String { provider.id }
    var currentProviderName: String { provider.displayName }

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
