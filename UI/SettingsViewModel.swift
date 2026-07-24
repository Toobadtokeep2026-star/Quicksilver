import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var apiKeyDraft: String = ""
    private(set) var hasStoredKey: Bool = false
    private(set) var providerName: String = ""
    private(set) var aiEnabled: Bool = false
    private(set) var statusMessage: String?
    private(set) var statusIsError: Bool = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        refresh()
    }

    func refresh() {
        let key = KeychainStore.string(forKey: AIService.apiKeyKeychainAccount)
        hasStoredKey = !(key?.isEmpty ?? true)
        providerName = container.aiService.currentProviderName
        aiEnabled = container.featureFlags.isEnabled("aiServiceEnabled")
        // Never put the real key into the draft field after load — only mask state
        if hasStoredKey && apiKeyDraft.isEmpty {
            apiKeyDraft = ""
        }
    }

    func saveAPIKey() {
        let trimmed = apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusMessage = "Enter a non-empty key"
            statusIsError = true
            return
        }

        container.aiService.configureAPIKey(trimmed)
        // Clear draft so the secret is not left in UI state longer than needed
        apiKeyDraft = ""
        refresh()

        if container.aiService.currentProviderID == "grok" {
            statusMessage = "Key saved. Provider: Grok"
            statusIsError = false
        } else if !aiEnabled {
            statusMessage = "Key saved to Keychain. Enable AI Service to use Grok."
            statusIsError = false
        } else {
            statusMessage = "Key saved. Provider: \(container.aiService.currentProviderName)"
            statusIsError = false
        }
    }

    func clearAPIKey() {
        container.aiService.configureAPIKey(nil)
        apiKeyDraft = ""
        refresh()
        statusMessage = "Key removed. Provider: Mock"
        statusIsError = false
    }

    func setAIEnabled(_ enabled: Bool) {
        container.featureFlags.set("aiServiceEnabled", enabled: enabled)
        // Re-evaluate provider now that the flag changed
        if enabled {
            let key = KeychainStore.string(forKey: AIService.apiKeyKeychainAccount)
            container.aiService.configureAPIKey(key)
        } else {
            // Keep key in Keychain but force Mock while disabled
            container.aiService.setProvider(MockAIProvider())
        }
        refresh()
        statusMessage = enabled ? "AI Service enabled" : "AI Service disabled (Mock only)"
        statusIsError = false
    }
}
