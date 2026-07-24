import Foundation
import Observation

@MainActor
@Observable
final class AskViewModel {
    var draft: String = ""
    private(set) var isProcessing = false
    private(set) var lastAnswer: String?
    private(set) var errorMessage: String?
    private(set) var providerName: String = ""

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        providerName = container.aiService.currentProviderName
    }

    func submit() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        isProcessing = true
        errorMessage = nil
        lastAnswer = nil
        providerName = container.aiService.currentProviderName

        let config = container.activeConfiguration
        let policy = container.personaManager.activeMemoryPolicy

        await container.memoryManager.load()
        let memoryQuery = MemoryQuery(
            personaScope: policy.prefersScopedView ? config.id : nil,
            minimumImportance: policy.retentionThreshold,
            limit: 5
        )
        let memories = container.memoryManager.items(matching: memoryQuery, policy: policy)
            .map { $0.value }

        let state = container.nexus.state
        let insightTitles = state.recentInsights.prefix(3).map { $0.title }
        var deviceParts: [String] = []
        if let level = state.batteryLevel {
            deviceParts.append("Battery \(Int(level * 100))%")
        }
        deviceParts.append("Network \(state.networkStatus)")
        deviceParts.append("Thermal \(state.thermalState)")

        let context = ContextAssembler.Input(
            personaID: config.id,
            personaDisplayName: config.displayName,
            recentMemorySnippets: memories,
            latestInsightTitles: Array(insightTitles),
            deviceSummary: deviceParts.joined(separator: ", ")
        )

        do {
            let response = try await container.aiService.complete(
                userMessage: text,
                personaSystemPrompt: config.systemPrompt,
                preferredTemperature: config.preferredTemperature,
                maxTokensHint: config.maxTokensHint,
                context: context
            )
            lastAnswer = response.content
            draft = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}
