import Foundation
import Core

/// Deterministic in-memory store for unit tests.
public actor InMemoryMemoryStore: MemoryStore {
    private var items: [MemoryItem] = []

    public init() {}

    public func loadAll() async throws -> [MemoryItem] {
        items
    }

    public func save(_ item: MemoryItem) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    public func delete(id: UUID) async throws {
        items.removeAll { $0.id == id }
    }

    public func deleteAll(in category: MemoryItem.Category) async throws {
        items.removeAll { $0.category == category }
    }
}
