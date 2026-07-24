import Foundation
import Observation

@MainActor
@Observable
final class MemoryViewModel {
    private(set) var items: [MemoryItem] = []
    private(set) var isLoading = false
    private(set) var activePolicyLabel: String = ""

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func load() async {
        isLoading = true
        await container.memoryManager.load()

        let personaID = container.personaManager.activePersonaID
        let policy = container.personaManager.activeMemoryPolicy
        activePolicyLabel = "threshold \(Int(policy.retentionThreshold * 100))%"

        let query = MemoryQuery(
            personaScope: policy.prefersScopedView ? personaID : nil,
            minimumImportance: policy.retentionThreshold
        )
        items = container.memoryManager.items(matching: query, policy: policy)
        isLoading = false
    }

    func addQuickNote(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let personaID = container.personaManager.activePersonaID
        let policy = container.personaManager.activeMemoryPolicy

        await container.memoryManager.set(
            key: "note.\(UUID().uuidString.prefix(8))",
            value: trimmed,
            category: .temporary,
            importanceBoost: policy.writeImportanceHint,
            personaScope: personaID
        )
        await load()
    }
}
