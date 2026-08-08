import SwiftUI
import Personas

enum PersonaTheme {
    static let cosmicBlack = Color(red: 0.025, green: 0.022, blue: 0.045)
    static let abyss = Color(red: 0.055, green: 0.040, blue: 0.085)
    static let deepViolet = Color(red: 0.25, green: 0.12, blue: 0.48)
    static let runicViolet = Color(red: 0.43, green: 0.29, blue: 1.0)
    static let mercurySilver = Color(red: 0.82, green: 0.84, blue: 0.90)
    static let liquidMetal = Color(red: 0.58, green: 0.62, blue: 0.70)
    static let emeraldAccent = Color(red: 0.28, green: 0.90, blue: 0.68)
    static let quicksilverCyan = Color(red: 0.55, green: 1.0, blue: 0.90)
    static let forgeEmber = Color(red: 1.0, green: 0.36, blue: 0.16)
    static let forgeGold = Color(red: 1.0, green: 0.72, blue: 0.30)
    static let eternalViolet = Color(red: 0.62, green: 0.45, blue: 1.0)
    static let subtleGold = forgeGold
    static let emberWarning = Color(red: 1.0, green: 0.48, blue: 0.28)

    static func accent(for personaID: String) -> Color {
        switch personaID.lowercased() {
        case "forge": return forgeEmber
        case "eternal": return eternalViolet
        case "quicksilver": return quicksilverCyan
        default: return emeraldAccent
        }
    }

    static func secondaryAccent(for personaID: String) -> Color {
        switch personaID.lowercased() {
        case "forge": return forgeGold
        case "eternal": return deepViolet
        default: return mercurySilver
        }
    }

    static func density(for personaID: String) -> CGFloat {
        switch personaID.lowercased() { case "forge": return 0.88; case "eternal": return 1.16; default: return 1.0 }
    }

    static func cardCornerRadius(for personaID: String) -> CGFloat {
        switch personaID.lowercased() { case "forge": return 14; case "eternal": return 24; default: return 20 }
    }

    static func glassOpacity(for personaID: String) -> Double {
        switch personaID.lowercased() { case "forge": return 0.18; case "eternal": return 0.09; default: return 0.14 }
    }

    static func assistantBubbleStyle(for personaID: String) -> (opacity: Double, weight: Font.Weight) {
        switch personaID.lowercased() { case "forge": return (0.12, .medium); case "eternal": return (0.08, .regular); default: return (0.15, .regular) }
    }

    static func spring(for personaID: String) -> Animation {
        switch personaID.lowercased() { case "forge": return .spring(response: 0.30, dampingFraction: 0.80); case "eternal": return .spring(response: 0.58, dampingFraction: 0.80); default: return .spring(response: 0.42, dampingFraction: 0.74) }
    }

    static let thinkingPulse = Animation.easeInOut(duration: 1.4).repeatForever(autoreverses: true)
    static let insightAppear = Animation.spring(response: 0.5, dampingFraction: 0.7)

    static func cardBackground(for personaID: String) -> some ShapeStyle { .ultraThinMaterial }
    static func borderColor(for personaID: String) -> Color { accent(for: personaID).opacity(0.35) }

    static func policySummary(for personaID: String) -> String {
        let policy = MemoryPolicy.policy(for: personaID)
        let threshold = Int(policy.retentionThreshold * 100)
        let scope = policy.prefersScopedView ? "scoped" : "shared"
        let write = policy.writeImportanceHint.map { Int($0 * 100) }.map { "write \($0)%" } ?? "write default"
        return "\(threshold)% retain · \(scope) · \(write)"
    }

    static func healthColor(_ score: Int) -> Color {
        switch score { case 80...: return emeraldAccent; case 50..<80: return subtleGold; default: return Color(red: 0.9, green: 0.3, blue: 0.3) }
    }
}
