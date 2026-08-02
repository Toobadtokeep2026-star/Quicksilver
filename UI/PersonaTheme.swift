import SwiftUI
import Personas

/// Presentation tokens driven by the active persona.
/// Keeps theming in UI — Personas stays free of SwiftUI.
enum PersonaTheme {

    static func accent(for personaID: String) -> Color {
        switch personaID.lowercased() {
        case "forge":
            return Color(red: 0.95, green: 0.55, blue: 0.20) // forgeOrange
        case "eternal":
            return Color(red: 0.62, green: 0.45, blue: 0.90) // eternalViolet
        case "quicksilver":
            return Color(red: 0.20, green: 0.85, blue: 0.90) // quicksilverCyan
        default:
            return Color.accentColor
        }
    }

    /// Vertical spacing multiplier for denser (Forge) vs airier (Eternal) layouts.
    static func density(for personaID: String) -> CGFloat {
        switch personaID.lowercased() {
        case "forge": return 0.85
        case "eternal": return 1.15
        default: return 1.0
        }
    }

    static func cardCornerRadius(for personaID: String) -> CGFloat {
        switch personaID.lowercased() {
        case "forge": return 12
        case "eternal": return 20
        default: return 16
        }
    }

    static func assistantBubbleStyle(for personaID: String) -> (opacity: Double, weight: Font.Weight) {
        switch personaID.lowercased() {
        case "forge":
            return (0.10, .medium)
        case "eternal":
            return (0.08, .regular)
        default:
            return (0.14, .regular)
        }
    }

    static func policySummary(for personaID: String) -> String {
        let policy = MemoryPolicy.policy(for: personaID)
        let threshold = Int(policy.retentionThreshold * 100)
        let scope = policy.prefersScopedView ? "scoped" : "shared"
        let write = policy.writeImportanceHint.map { Int($0 * 100) }.map { "write \($0)%" } ?? "write default"
        return "\(threshold)% retain · \(scope) · \(write)"
    }
}
