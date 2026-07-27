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
                title: insight.title,
                body: forgeBody(insight.body),
                action: insight.suggestedAction.map { "Next: \($0)" },
                styleLabel: "Forge"
            )
        case "eternal":
            return Display(
                title: insight.title,
                body: eternalBody(insight.body),
                action: insight.suggestedAction,
                styleLabel: "Eternal"
            )
        case "quicksilver":
            return Display(
                title: insight.title,
                body: quicksilverBody(insight.body),
                action: insight.suggestedAction,
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

    private static func forgeBody(_ body: String) -> String {
        if body.hasSuffix(".") {
            return body + " Assess impact before acting."
        }
        return body + ". Assess impact before acting."
    }

    private static func eternalBody(_ body: String) -> String {
        if body.hasSuffix(".") {
            return body + " Consider continuity with prior context."
        }
        return body + ". Consider continuity with prior context."
    }

    /// Light verbal edge — sharp, not theatrical.
    private static func quicksilverBody(_ body: String) -> String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return body }

        // Keep it dry and cutting rather than adding long flourishes.
        if trimmed.hasSuffix(".") {
            return trimmed + " Obvious, once you look."
        }
        return trimmed + ". Obvious, once you look."
    }
}
