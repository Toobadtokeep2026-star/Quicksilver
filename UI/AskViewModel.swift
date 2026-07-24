import Foundation
import Observation

struct ChatTurn: Identifiable, Equatable {
    let id: UUID
    let role: Role
    let text: String
    let createdAt: Date

    enum Role: String {
        case user, assistant
    }
}

@MainActor
@Observable
final class AskViewModel {
    var draft: String = ""
    private(set) var isProcessing = false
    private(set) var turns: [ChatTurn] = []
    private(set) var errorMessage: String?
    private(set) var providerName: String = ""

    private let container: DependencyContainer
    private let historyLimit = 40

    init(container: DependencyContainer) {
        self.container = container
        providerName = container.aiService.currentProviderName
    }

    func loadHistory() async {
        await container.memoryManager.load()
        let personaID = container.personaManager.activePersonaID
        let query = MemoryQuery(
            category: .conversation,
            personaScope: personaID,
            keyPrefix: "chat.",
            limit: historyLimit
        )
        // MemoryQuery sorts by importance then recency; for chat we want chronological
        let items = container.memoryManager.items(matching: query)
            .sorted { $0.createdAt < $1.createdAt }

        turns = items.compactMap { item in
            let role: ChatTurn.Role = item.metadata["role"] == "assistant" ? .assistant : .user
            return ChatTurn(id: item.id, role: role, text: item.value, createdAt: item.createdAt)
        }
    }

    func submit() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        isProcessing = true
        errorMessage = nil
        providerName = container.aiService.currentProviderName

        let config = container.activeConfiguration
        let policy = container.personaManager.activeMemoryPolicy
        let personaID = config.id

        // Optimistic user turn
        let userTurn = ChatTurn(id: UUID(), role: .user, text: text, createdAt: Date())
        turns.append(userTurn)
        draft = ""

        await persistTurn(userTurn, personaID: personaID, policy: policy)

        await container.memoryManager.load()
        let memoryQuery = MemoryQuery(
            personaScope: policy.prefersScopedView ? personaID : nil,
            minimumImportance: policy.retentionThreshold,
            limit: 5
        )
        let memories = container.memoryManager.items(matching: memoryQuery, policy: policy)
            .filter { $0.category != .conversation }
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
            let assistantTurn = ChatTurn(
                id: UUID(),
                role: .assistant,
                text: response.content,
                createdAt: Date()
            )
            turns.append(assistantTurn)
            await persistTurn(assistantTurn, personaID: personaID, policy: policy)
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func persistTurn(_ turn: ChatTurn, personaID: String, policy: MemoryPolicy) async {
        let key = "chat.\(turn.createdAt.timeIntervalSince1970).\(turn.id.uuidString.prefix(8))"
        await container.memoryManager.set(
            key: key,
            value: turn.text,
            category: .conversation,
            metadata: [
                "role": turn.role.rawValue,
                "persona": personaID
            ],
            importanceBoost: turn.role == .assistant ? policy.writeImportanceHint : 0.45,
            personaScope: personaID
        )
    }
}
