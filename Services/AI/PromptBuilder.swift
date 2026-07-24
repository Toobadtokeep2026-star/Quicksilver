import Foundation
import Core

/// Builds the final system + user prompt pair.
/// Pure and testable. Views must not construct prompts directly.
struct PromptBuilder: Sendable {

    struct Result: Sendable {
        let systemPrompt: String
        let userPrompt: String
        let temperature: Double
        let maxTokens: Int
    }

    /// Assemble a request for the given persona and user message.
    func build(
        personaSystemPrompt: String,
        preferredTemperature: Double,
        maxTokensHint: Int,
        userMessage: String,
        assembledContext: String?
    ) -> Result {
        var system = personaSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

        if let context = assembledContext?.trimmingCharacters(in: .whitespacesAndNewlines),
           !context.isEmpty {
            system += "\n\n## Active Context\n" + context
        }

        return Result(
            systemPrompt: system,
            userPrompt: userMessage.trimmingCharacters(in: .whitespacesAndNewlines),
            temperature: preferredTemperature,
            maxTokens: maxTokensHint
        )
    }
}
