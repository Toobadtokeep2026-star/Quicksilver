import Foundation

/// Protocol that every concrete AI backend must satisfy.
/// Keeps Quicksilver free of vendor lock-in.
protocol AIProvider: Sendable {
    var id: String { get }
    var displayName: String { get }
    var isAvailable: Bool { get }

    func complete(_ request: AIRequest) async throws -> AIResponse
}

/// Simple mock provider for development and tests.
/// Returns a deterministic response so the rest of the system can be exercised offline.
struct MockAIProvider: AIProvider {
    let id = "mock"
    let displayName = "Mock Provider"
    let isAvailable = true

    func complete(_ request: AIRequest) async throws -> AIResponse {
        // Simulate a tiny bit of latency
        try await Task.sleep(nanoseconds: 80_000_000)

        let content = """
        [Mock response for persona system]
        Prompt received: \(request.prompt.prefix(80))...
        System: \(request.systemPrompt?.prefix(40) ?? "none")
        """

        return AIResponse(
            requestID: request.id,
            content: content,
            finishReason: .stop,
            usage: .init(promptTokens: 42, completionTokens: 28)
        )
    }
}
