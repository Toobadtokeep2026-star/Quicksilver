import Foundation
import Core

/// Assembles a compact, privacy-safe context block for the model.
/// Pure. No network, no storage side effects.
struct ContextAssembler: Sendable {

    struct Input: Sendable {
        var personaID: String?
        var personaDisplayName: String?
        var recentMemorySnippets: [String]
        var latestInsightTitles: [String]
        var deviceSummary: String?

        init(
            personaID: String? = nil,
            personaDisplayName: String? = nil,
            recentMemorySnippets: [String] = [],
            latestInsightTitles: [String] = [],
            deviceSummary: String? = nil
        ) {
            self.personaID = personaID
            self.personaDisplayName = personaDisplayName
            self.recentMemorySnippets = recentMemorySnippets
            self.latestInsightTitles = latestInsightTitles
            self.deviceSummary = deviceSummary
        }
    }

    /// Produce a short context string. Empty if nothing useful is available.
    func assemble(_ input: Input, maxMemoryLines: Int = 5, maxInsightLines: Int = 3) -> String? {
        var lines: [String] = []

        if let name = input.personaDisplayName, !name.isEmpty {
            lines.append("Active persona: \(name)")
        } else if let id = input.personaID {
            lines.append("Active persona: \(id)")
        }

        if let device = input.deviceSummary?.trimmingCharacters(in: .whitespacesAndNewlines),
           !device.isEmpty {
            lines.append("Device: \(device)")
        }

        let memories = input.recentMemorySnippets
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(maxMemoryLines)
        if !memories.isEmpty {
            lines.append("Recent memory:")
            for m in memories {
                lines.append("- \(m.prefix(160))")
            }
        }

        let insights = input.latestInsightTitles
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(maxInsightLines)
        if !insights.isEmpty {
            lines.append("Recent insights:")
            for i in insights {
                lines.append("- \(i.prefix(120))")
            }
        }

        guard !lines.isEmpty else { return nil }
        return lines.joined(separator: "\n")
    }
}
