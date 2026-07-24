import Foundation
import Core

// AIProvider protocol now lives in Core/Protocols/AIProvider.swift.
// This file only provides the Mock implementation used by default.

public struct MockAIProvider: AIProvider {
    public let id = "mock"
    public let displayName = "Mock Provider"
    public let isAvailable = true

    public init() {}

    public func complete(_ request: AIRequest) async throws -> AIResponse {
        try await Task.sleep(nanoseconds: 80_000_000)
        let content = "[Mock response]\nPrompt: \(request.prompt.prefix(80))...\nSystem: \(request.systemPrompt?.prefix(40) ?? "none")"
        return AIResponse(
            requestID: request.id,
            content: content,
            finishReason: .stop,
            usage: .init(promptTokens: 42, completionTokens: 28)
        )
    }
}
