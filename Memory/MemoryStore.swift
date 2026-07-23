import Foundation

/// Persistence protocol for memory.
/// Day Two: UserDefaults-backed. Future implementations can swap to SwiftData / files without changing callers.
protocol MemoryStore: Sendable {
    func loadAll() async throws -> [MemoryItem]
    func save(_ item: MemoryItem) async throws
    func delete(id: UUID) async throws
    func deleteAll(in category: MemoryItem.Category) async throws
}

/// Simple UserDefaults-backed store.
/// Privacy-first: data never leaves the device. Suitable for preferences and lightweight context.
actor UserDefaultsMemoryStore: MemoryStore {
    private let defaults: UserDefaults
    private let storageKey = "quicksilver.memory.items"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadAll() async throws -> [MemoryItem] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return try JSONDecoder().decode([MemoryItem].self, from: data)
    }

    func save(_ item: MemoryItem) async throws {
        var items = try await loadAll()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        let data = try JSONEncoder().encode(items)
        defaults.set(data, forKey: storageKey)
    }

    func delete(id: UUID) async throws {
        var items = try await loadAll()
        items.removeAll { $0.id == id }
        let data = try JSONEncoder().encode(items)
        defaults.set(data, forKey: storageKey)
    }

    func deleteAll(in category: MemoryItem.Category) async throws {
        var items = try await loadAll()
        items.removeAll { $0.category == category }
        let data = try JSONEncoder().encode(items)
        defaults.set(data, forKey: storageKey)
    }
}
