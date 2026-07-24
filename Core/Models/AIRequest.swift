import Foundation

/// Request sent to any AIProvider.
public struct AIRequest: Sendable, Identifiable {
    public let id: UUID
    public let prompt: String
    public let systemPrompt: String?
    public let temperature: Double
    public let maxTokens: Int
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        prompt: String,
        systemPrompt: String? = nil,
        temperature: Double = 0.7,
        maxTokens: Int = 1024,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.metadata = metadata
    }
}
