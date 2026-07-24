import Foundation
import Core

/// Memory retention and visibility policy influenced by the active persona.
/// Pure value type — easy to test and later replace with learned policy.
public struct MemoryPolicy: Sendable {

    /// Minimum importance that should be retained long-term for this persona.
    public let retentionThreshold: Double

    /// Whether this persona prefers to see only its own scoped memories + shared.
    public let prefersScopedView: Bool

    /// Default category boost when this persona writes a memory.
    public let writeImportanceHint: Double?

    public init(
        retentionThreshold: Double = 0.4,
        prefersScopedView: Bool = true,
        writeImportanceHint: Double? = nil
    ) {
        self.retentionThreshold = min(max(retentionThreshold, 0), 1)
        self.prefersScopedView = prefersScopedView
        self.writeImportanceHint = writeImportanceHint.map { min(max($0, 0), 1) }
    }

    // MARK: - Built-in policies

    public static let forge = MemoryPolicy(
        retentionThreshold: 0.55,
        prefersScopedView: true,
        writeImportanceHint: 0.7
    )

    public static let quicksilver = MemoryPolicy(
        retentionThreshold: 0.4,
        prefersScopedView: false,
        writeImportanceHint: 0.5
    )

    public static let eternal = MemoryPolicy(
        retentionThreshold: 0.3,
        prefersScopedView: false,
        writeImportanceHint: 0.75
    )

    public static func policy(for personaID: String) -> MemoryPolicy {
        switch personaID {
        case "forge": return .forge
        case "eternal": return .eternal
        default: return .quicksilver
        }
    }
}
