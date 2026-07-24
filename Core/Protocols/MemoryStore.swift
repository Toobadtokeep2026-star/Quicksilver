import Foundation

/// Contract for persistent memory storage.
/// Implementations live in the Memory module (UserDefaults, SwiftData, etc.).
public protocol MemoryStore: Sendable {
    func loadAll() async throws -> [MemoryItem]
    func save(_ item: MemoryItem) async throws
    func delete(id: UUID) async throws
    func deleteAll(in category: MemoryItem.Category) async throws
}
