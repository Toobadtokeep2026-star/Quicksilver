import Foundation
import Core

/// Simple, testable query surface over memory items.
/// No vector search, no cloud. Pure filtering + ranking.
public struct MemoryQuery: Sendable {

    public var category: MemoryItem.Category?
    public var personaScope: String?
    public var minimumImportance: Double?
    public var keyPrefix: String?
    public var limit: Int?

    public init(
        category: MemoryItem.Category? = nil,
        personaScope: String? = nil,
        minimumImportance: Double? = nil,
        keyPrefix: String? = nil,
        limit: Int? = nil
    ) {
        self.category = category
        self.personaScope = personaScope
        self.minimumImportance = minimumImportance
        self.keyPrefix = keyPrefix
        self.limit = limit
    }

    /// Apply the query to an in-memory collection. Deterministic and pure.
    public func apply(to items: [MemoryItem]) -> [MemoryItem] {
        var result = items

        if let category {
            result = result.filter { $0.category == category }
        }
        if let personaScope {
            result = result.filter { $0.personaScope == nil || $0.personaScope == personaScope }
        }
        if let minimumImportance {
            result = result.filter { $0.importance >= minimumImportance }
        }
        if let keyPrefix {
            result = result.filter { $0.key.hasPrefix(keyPrefix) }
        }

        result.sort {
            if $0.importance != $1.importance { return $0.importance > $1.importance }
            return $0.updatedAt > $1.updatedAt
        }

        if let limit, limit > 0 {
            result = Array(result.prefix(limit))
        }

        return result
    }
}
