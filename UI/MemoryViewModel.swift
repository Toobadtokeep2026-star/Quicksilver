import Foundation
import Observation

@MainActor
@Observable
final class MemoryViewModel {
    private(set) var items: [MemoryItem] = []
    private(set) var isLoading = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func load() async {
        isLoading = true
        await container.memoryManager.load()
        // Show items relevant to the active persona, ranked by importance
        let personaID = container.activeConfiguration.id
        items = container.memoryManager.items(forPersona: personaID)
        isLoading = false
    }

    func addQuickNote(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let personaID = container.activeConfiguration.id
        await container.memoryManager.set(
            key: "note.\(UUID().uuidString.prefix(8))",
            value: trimmed,
            category: .temporary,
            personaScope: personaID
        )
        await load()
    }
}
