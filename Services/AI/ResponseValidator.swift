import Foundation
import Core

/// Lightweight validation of model responses before they enter app state.
enum ResponseValidator: Sendable {

    enum Outcome: Sendable {
        case accept(AIResponse)
        case reject(reason: String)
    }

    static func validate(_ response: AIResponse) -> Outcome {
        let trimmed = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .reject(reason: "Empty model response")
        }

        // Hard cap to protect UI and memory from pathological outputs
        if trimmed.count > 32_000 {
            let clipped = String(trimmed.prefix(32_000))
            let clippedResponse = AIResponse(
                id: response.id,
                requestID: response.requestID,
                content: clipped,
                finishReason: .length,
                usage: response.usage,
                createdAt: response.createdAt
            )
            return .accept(clippedResponse)
        }

        return .accept(response)
    }
}
