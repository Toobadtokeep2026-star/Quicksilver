import Foundation
import Nexus

/// Presentation-only helper.
/// Takes a neutral Insight + active persona and produces display strings.
/// Never mutates the stored Insight.
enum InsightPresenter {

    struct Display {
        let title: String
        let body: String
        let action: String?
        let styleLabel: String
    }

    static func present(_ insight: Insight, personaID: String) -> Display {
        switch personaID.lowercased() {
        case "forge":
            return Display(
                title: forgeTitle(insight.title),
                body: forgeBody(insight.body),
                action: insight.suggestedAction.map { "Next: \($0)" },
                styleLabel: "Forge"
            )
        case "eternal":
            return Display(
                title: insight.title,
                body: eternalBody(insight.body),
                action: insight.suggestedAction.map { "Hold: \($0)" },
                styleLabel: "Eternal"
            )
        case "quicksilver":
            return Display(
                title: insight.title,
                body: quicksilverBody(insight.body),
                action: insight.suggestedAction.map { "Move: \($0)" },
                styleLabel: "Quicksilver"
            )
        default:
            return Display(
                title: insight.title,
                body: insight.body,
                action: insight.suggestedAction,
                styleLabel: "Quicksilver"
            )
        }
    }

    // MARK: - Forge — precise, structural

    private static func forgeTitle(_ title: String) -> String {
        title
    }

    private static func forgeBody(_ body: String) -> String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return body }
        if trimmed.hasSuffix(".") {
            return trimmed + " Assess impact before acting."
        }
        return trimmed + ". Assess impact before acting."
    }

    // MARK: - Eternal — continuity, long horizon

    private static func eternalBody(_ body: String) -> String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return body }
        if trimmed.hasSuffix(".") {
            return trimmed + " Weigh continuity with prior context."
        }
        return trimmed + ". Weigh continuity with prior context."
    }

    // MARK: - Quicksilver — sharp, dry, cutting

    private static func quicksilverBody(_ body: String) -> String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return body }

        if trimmed.hasSuffix(".") {
            return trimmed + " Obvious, once you look."
        }
        return trimmed + ". Obvious, once you look."
    }
}
