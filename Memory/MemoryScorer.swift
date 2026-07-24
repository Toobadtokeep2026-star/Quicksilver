import Foundation
import Core

/// Lightweight, pure importance scorer.
/// Keeps scoring deterministic and testable so Eternal can later replace it with a learned model.
enum MemoryScorer {

    private static let categoryBase: [MemoryItem.Category: Double] = [
        .system: 0.85,
        .preference: 0.75,
        .project: 0.70,
        .conversation: 0.45,
        .temporary: 0.25
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
}
