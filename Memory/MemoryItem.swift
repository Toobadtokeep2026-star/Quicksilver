import Foundation

/// Single memory record.
/// Designed for local-first storage and future expansion to more sophisticated stores.
struct MemoryItem: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let key: String
    let category: Category
    var value: String
    let createdAt: Date
    var updatedAt: Date
    var metadata: [String: String]

    enum Category: String, Codable, Sendable, CaseIterable {
        case preference
        case conversation
        case project
        case system
        case temporary
    }

    init(
        id: UUID = UUID(),
        key: String,
        category: Category,
        value: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.key = key
        self.category = category
        self.value = value
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.metadata = metadata
    }
}
