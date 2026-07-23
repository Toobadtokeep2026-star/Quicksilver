import Foundation

struct AIRequest: Sendable, Identifiable {
    let id: UUID
    let prompt: String
    let systemPrompt: String?
    let temperature: Double
    let maxTokens: Int
    let metadata: [String: String]

    init(id: UUID = UUID(), prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 1024, metadata: [String: String] = [:]) {
        self.id = id
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.metadata = metadata
    }
}
