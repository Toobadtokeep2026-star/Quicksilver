import Foundation

protocol AIProvider: Sendable {
    var id: String { get }
    var displayName: String { get }
    var isAvailable: Bool { get }
    func complete(_ request: AIRequest) async throws -> AIResponse
}

struct MockAIProvider: AIProvider {
    let id = "mock"
    let displayName = "Mock Provider"
    let isAvailable = true

    func complete(_ request: AIRequest) async throws -> AIResponse {
        try await Task.sleep(nanoseconds: 80_000_000)
        let content = "[Mock response]\nPrompt: \(request.prompt.prefix(80))...\nSystem: \(request.systemPrompt?.prefix(40) ?? "none")"
        return AIResponse(requestID: request.id, content: content, finishReason: .stop, usage: .init(promptTokens: 42, completionTokens: 28))
    }
}
