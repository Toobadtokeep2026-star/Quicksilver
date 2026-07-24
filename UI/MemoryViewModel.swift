import Foundation
import Observation

@MainActor
@Observable
final class MemoryViewModel {
    private(set) var items: [MemoryItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        await container.memoryManager.load()
        items = container.memoryManager.items.sorted { $0.updatedAt > $1.updatedAt }
        isLoading = false
    }

    func addQuickNote(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        await container.memoryManager.set(
            key: "note.\(UUID().uuidString.prefix(8))",
            value: trimmed,
            category: .note
        )
        await load()
    }
}
