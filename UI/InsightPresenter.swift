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
}
