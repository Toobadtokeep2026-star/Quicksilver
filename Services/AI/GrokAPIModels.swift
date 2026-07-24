import Foundation

enum GrokAPI {
    struct ChatRequest: Encodable {
        let model: String
        let messages: [Message]
        let temperature: Double
        let max_tokens: Int
        let stream: Bool

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    struct ChatResponse: Decodable {
        let id: String?
        let choices: [Choice]
        let usage: Usage?

        struct Choice: Decodable {
            let message: Message
            let finish_reason: String?
        }

        struct Message: Decodable {
            let role: String?
            let content: String
        }

        struct Usage: Decodable {
            let prompt_tokens: Int?
            let completion_tokens: Int?
            let total_tokens: Int?
        }
    }
}
