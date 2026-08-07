import SwiftUI
import Personas

/// Full design token system for Mercury: Quicksilver.
/// Cosmic black · deep violet · mercury silver · emerald · subtle gold · glass · liquid metal.
/// Tokens are persona-reactive where it serves identity; the overall identity is Mercury.
enum PersonaTheme {

    // MARK: - Core Palette (Mercury Identity)

    static let cosmicBlack = Color(red: 0.04, green: 0.04, blue: 0.07)
    static let deepViolet = Color(red: 0.28, green: 0.15, blue: 0.42)
    static let mercurySilver = Color(red: 0.78, green: 0.80, blue: 0.84)
    static let emeraldAccent = Color(red: 0.20, green: 0.72, blue: 0.55)
    static let subtleGold = Color(red: 0.82, green: 0.68, blue: 0.38)
    static let liquidMetal = Color(red: 0.55, green: 0.58, blue: 0.65)

    // MARK: - Persona Accents (still used for identity shifts)

    static func accent(for personaID: String) -> Color {
        switch personaID.lowercased() {
        case "forge":
            return Color(red: 0.95, green: 0.55, blue: 0.20) // forgeOrange
        case "eternal":
            return Color(red: 0.62, green: 0.45, blue: 0.90) // eternalViolet
        case "quicksilver":
            return Color(red: 0.20, green: 0.85, blue: 0.90) // quicksilverCyan
        default:
            return emeraldAccent
        }
    }

    static func secondaryAccent(for personaID: String) -> Color {
        switch personaID.lowercased() {
        case "forge": return subtleGold
        case "eternal": return deepViolet
        default: return mercurySilver
        }
    }

    // MARK: - Density & Geometry

    /// Vertical spacing multiplier: denser (Forge) vs airier (Eternal).
    static func density(for personaID: String) -> CGFloat {
        switch personaID.lowercased() {
        case "forge": return 0.85
        case "eternal": return 1.18
        default: return 1.0
        }
    }

    static func cardCornerRadius(for personaID: String) -> CGFloat {
        switch personaID.lowercased() {
        case "forge": return 12
        case "eternal": return 22
        default: return 16
        }
    }

    static func glassOpacity(for personaID: String) -> Double {
        switch personaID.lowercased() {
        case "forge": return 0.12
        case "eternal": return 0.08
        default: return 0.14
        }
    }

    // MARK: - Typography & Bubbles

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

    // MARK: - Motion Curves (meaningful animation)

    static func spring(for personaID: String) -> Animation {
        switch personaID.lowercased() {
        case "forge":
            return .spring(response: 0.32, dampingFraction: 0.82)
        case "eternal":
            return .spring(response: 0.55, dampingFraction: 0.78)
        default:
            return .spring(response: 0.42, dampingFraction: 0.75)
        }
    }

    static let thinkingPulse = Animation.easeInOut(duration: 1.4).repeatForever(autoreverses: true)
    static let insightAppear = Animation.spring(response: 0.5, dampingFraction: 0.7)

    // MARK: - Materials

    static func cardBackground(for personaID: String) -> some ShapeStyle {
        .ultraThinMaterial
    }

    static func borderColor(for personaID: String) -> Color {
        accent(for: personaID).opacity(0.35)
    }

    // MARK: - Policy Summary (legacy helper)

    static func policySummary(for personaID: String) -> String {
        let policy = MemoryPolicy.policy(for: personaID)
        let threshold = Int(policy.retentionThreshold * 100)
        let scope = policy.prefersScopedView ? "scoped" : "shared"
        let write = policy.writeImportanceHint.map { Int($0 * 100) }.map { "write \($0)%" } ?? "write default"
        return "\(threshold)% retain · \(scope) · \(write)"
    }

    // MARK: - Living Status Colors

    static func healthColor(_ score: Int) -> Color {
        switch score {
        case 80...: return emeraldAccent
        case 50..<80: return subtleGold
        default: return Color(red: 0.9, green: 0.3, blue: 0.3)
        }
    }
}
