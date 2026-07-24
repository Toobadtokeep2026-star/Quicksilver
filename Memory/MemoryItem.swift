import Foundation

struct MemoryItem: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let key: String
    let category: Category
    var value: String
    let createdAt: Date
    var updatedAt: Date
    var metadata: [String: String]

    /// Importance in the range 0.0 ... 1.0. Higher = more durable / more relevant to Eternal.
    var importance: Double

    /// If set, this memory is primarily owned by / relevant to a specific persona.
    /// nil means shared across all personas.
    var personaScope: String?

    enum Category: String, Codable, Sendable, CaseIterable {
        case preference, conversation, project, system, temporary
    }

    init(
        id: UUID = UUID(),
        key: String,
        category: Category,
        value: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        metadata: [String: String] = [:],
        importance: Double = 0.5,
        personaScope: String? = nil
    ) {
        self.id = id
        self.key = key
        self.category = category
        self.value = value
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.metadata = metadata
        self.importance = min(max(importance, 0), 1)
        self.personaScope = personaScope
    }

    // MARK: - Codable (backward compatible with items written before importance/scope existed)

    enum CodingKeys: String, CodingKey {
        case id, key, category, value, createdAt, updatedAt, metadata, importance, personaScope
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        key = try c.decode(String.self, forKey: .key)
        category = try c.decode(Category.self, forKey: .category)
        value = try c.decode(String.self, forKey: .value)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        metadata = try c.decodeIfPresent([String: String].self, forKey: .metadata) ?? [:]
        importance = try c.decodeIfPresent(Double.self, forKey: .importance) ?? 0.5
        personaScope = try c.decodeIfPresent(String.self, forKey: .personaScope)
    }
}
