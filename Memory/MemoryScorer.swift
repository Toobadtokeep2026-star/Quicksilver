import Foundation

/// Lightweight, pure importance scorer.
/// Keeps scoring deterministic and testable so Eternal can later replace it with a learned model.
enum MemoryScorer {

    /// Base importance by category.
    private static let categoryBase: [MemoryItem.Category: Double] = [
        .system: 0.85,
        .preference: 0.75,
        .project: 0.70,
        .conversation: 0.45,
        .temporary: 0.25
    ]

    /// Compute importance for a new or updated item.
    /// - Parameters:
    ///   - category: Memory category
    ///   - value: Content
    ///   - explicitBoost: Optional caller-supplied boost (0...1)
    ///   - existing: Previous importance when updating
    static func score(
        category: MemoryItem.Category,
        value: String,
        explicitBoost: Double? = nil,
        existing: Double? = nil
    ) -> Double {
        var score = categoryBase[category] ?? 0.5

        // Longer durable content is slightly more important
        let lengthFactor = min(Double(value.count) / 400.0, 0.15)
        score += lengthFactor

        if let boost = explicitBoost {
            score = max(score, min(max(boost, 0), 1))
        }

        // On update, never let importance collapse below the previous value without an explicit low boost
        if let existing, explicitBoost == nil {
            score = max(score, existing)
        }

        return min(max(score, 0), 1)
    }
}
