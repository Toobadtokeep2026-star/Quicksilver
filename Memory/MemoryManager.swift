import Foundation
import Observation
import Core

@MainActor
@Observable
final class MemoryManager {
    private(set) var items: [MemoryItem] = []

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

    /// Write or update a memory item.
    func set(
        key: String,
        value: String,
        category: MemoryItem.Category,
        metadata: [String: String] = [:],
        importanceBoost: Double? = nil,
        personaScope: String? = nil
    ) async {
        if let existing = items.first(where: { $0.key == key && $0.category == category }) {
            var updated = existing
            updated.value = value
            updated.updatedAt = Date()
            updated.metadata = metadata
            updated.importance = MemoryScorer.score(
                category: category,
                value: value,
                explicitBoost: importanceBoost,
                existing: existing.importance
            )
            if let personaScope { updated.personaScope = personaScope }
            await persist(updated)
        } else {
            let importance = MemoryScorer.score(
                category: category,
                value: value,
                explicitBoost: importanceBoost
            )
            let item = MemoryItem(
                key: key,
                category: category,
                value: value,
                metadata: metadata,
                importance: importance,
                personaScope: personaScope
            )
            await persist(item)
        }
    }

    func value(for key: String, category: MemoryItem.Category) -> String? {
        items.first { $0.key == key && $0.category == category }?.value
    }

    /// Items visible to a given persona (shared + scoped), sorted by importance then recency.
    func items(forPersona personaID: String?) -> [MemoryItem] {
        let filtered: [MemoryItem]
        if let personaID {
            filtered = items.filter { $0.personaScope == nil || $0.personaScope == personaID }
        } else {
            filtered = items
        }
        return filtered.sorted {
            if $0.importance != $1.importance { return $0.importance > $1.importance }
            return $0.updatedAt > $1.updatedAt
        }
    }

    /// Policy-aware query: applies persona scope preference + retention threshold.
    func items(matching query: MemoryQuery, policy: MemoryPolicy? = nil) -> [MemoryItem] {
        var effective = query
        if let policy {
            if effective.minimumImportance == nil {
                effective = MemoryQuery(
                    category: query.category,
                    personaScope: query.personaScope,
                    minimumImportance: policy.retentionThreshold,
                    keyPrefix: query.keyPrefix,
                    limit: query.limit
                )
            }
        }
        return effective.apply(to: items)
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

    /// User-initiated full wipe. Irreversible.
    func clearAll() async {
        let ids = items.map(\.id)
        for id in ids {
            await delete(id: id)
        }
        items.removeAll()
        logger.info("Memory cleared by user request", category: logger.memory)
    }

    /// Privacy-respecting export. Returns a JSON string of current items.
    /// Callers are responsible for deciding whether and how to share the data.
    func exportJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(items)
        guard let json = String(data: data, encoding: .utf8) else {
            throw AppError.configurationMissing("Unable to encode memory export")
        }
        return json
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
