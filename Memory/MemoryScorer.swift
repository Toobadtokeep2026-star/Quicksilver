import Foundation
import Core

/// Lightweight, pure importance scorer + decay.
/// Keeps scoring deterministic and testable.
enum MemoryScorer {

    private static let categoryBase: [MemoryItem.Category: Double] = [
        .system: 0.85,
        .preference: 0.75,
        .project: 0.70,
        .conversation: 0.45,
        .temporary: 0.25
    ]

    /// Half-life in days for decay. Temporary memories decay fastest.
    private static let halfLifeDays: [MemoryItem.Category: Double] = [
        .temporary: 2,
        .conversation: 7,
        .project: 30,
        .preference: 90,
        .system: 180
    ]

    static func score(
        category: MemoryItem.Category,
        value: String,
        explicitBoost: Double? = nil,
        existing: Double? = nil
    ) -> Double {
        var score = categoryBase[category] ?? 0.5

        let lengthFactor = min(Double(value.count) / 400.0, 0.15)
        score += lengthFactor

        if let boost = explicitBoost {
            score = max(score, min(max(boost, 0), 1))
        }

        if let existing, explicitBoost == nil {
            score = max(score, existing)
        }

        return min(max(score, 0), 1)
    }

    /// Returns a decayed importance value based on time since last update.
    /// Pure function — does not mutate the stored item.
    static func decayedImportance(for item: MemoryItem, now: Date = Date()) -> Double {
        let halfLife = halfLifeDays[item.category] ?? 14
        let ageDays = max(now.timeIntervalSince(item.updatedAt) / 86_400, 0)
        // Exponential decay: importance * 0.5^(age/halfLife)
        let factor = pow(0.5, ageDays / halfLife)
        let decayed = item.importance * factor
        // Floor so very old items don't vanish completely from policy views unless they were already low
        return min(max(decayed, 0.05), 1)
    }
}
