import Foundation

/// High-level memory API used by the rest of the system.
@MainActor
final class MemoryManager: ObservableObject {
    @Published private(set) var items: [MemoryItem] = []

    private let store: MemoryStore
    private let eventBus: EventBus
    private let logger: LoggerService

    init(store: MemoryStore, eventBus: EventBus, logger: LoggerService) {
        self.store = store
        self.eventBus = eventBus
        self.logger = logger
    }

    func load() async {
        do {
            items = try await store.loadAll()
            logger.info("Loaded \(items.count) memory items", category: logger.memory)
        } catch {
            logger.error("Failed to load memory: \(error.localizedDescription)", category: logger.memory)
        }
    }

    func set(key: String, value: String, category: MemoryItem.Category, metadata: [String: String] = [:]) async {
        if let existing = items.first(where: { $0.key == key && $0.category == category }) {
            var updated = existing
            updated.value = value
            updated.updatedAt = Date()
            updated.metadata = metadata
            await persist(updated)
        } else {
            let item = MemoryItem(key: key, category: category, value: value, metadata: metadata)
            await persist(item)
        }
    }

    func value(for key: String, category: MemoryItem.Category) -> String? {
        items.first { $0.key == key && $0.category == category }?.value
    }

    func delete(id: UUID) async {
        do {
            try await store.delete(id: id)
            items.removeAll { $0.id == id }
            await eventBus.publish(.memoryDidUpdate(itemID: id.uuidString))
        } catch {
            logger.error("Failed to delete memory item: \(error.localizedDescription)", category: logger.memory)
        }
    }

    private func persist(_ item: MemoryItem) async {
        do {
            try await store.save(item)
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            } else {
                items.append(item)
            }
            await eventBus.publish(.memoryDidUpdate(itemID: item.id.uuidString))
        } catch {
            logger.error("Failed to save memory item: \(error.localizedDescription)", category: logger.memory)
        }
    }
}
