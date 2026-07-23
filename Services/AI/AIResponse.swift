import Foundation

struct AIResponse: Sendable, Identifiable {
    let id: UUID
    let requestID: UUID
    let content: String
    let finishReason: FinishReason
    let usage: Usage?
    let createdAt: Date

    enum FinishReason: String, Sendable {
        case stop, length, error, cancelled
    }

    struct Usage: Sendable {
        let promptTokens: Int
        let completionTokens: Int
        var totalTokens: Int { promptTokens + completionTokens }
    }

    init(id: UUID = UUID(), requestID: UUID, content: String, finishReason: FinishReason = .stop, usage: Usage? = nil, createdAt: Date = Date()) {
        self.id = id
        self.requestID = requestID
        self.content = content
        self.finishReason = finishReason
        self.usage = usage
        self.createdAt = createdAt
    }
}
