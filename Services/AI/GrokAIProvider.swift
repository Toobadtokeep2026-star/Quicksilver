import Foundation

/// Real AI provider targeting the xAI / Grok API (OpenAI-compatible chat completions).
/// Requires a valid API key stored in Keychain under `xai.apiKey`.
/// Never logs the key or request bodies that could contain secrets.
struct GrokAIProvider: AIProvider {
    let id = "grok"
    let displayName = "Grok (xAI)"

    private let apiKey: String
    private let baseURL: URL
    private let model: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// - Parameters:
    ///   - apiKey: Must be non-empty. Caller is responsible for loading from Keychain.
    ///   - model: Defaults to a current high-capability Grok model.
    ///   - baseURL: Defaults to the public xAI endpoint. Fails fast if the constant is malformed.
    init(
        apiKey: String,
        model: String = "grok-3",
        baseURL: URL? = nil,
        session: URLSession = .shared
    ) throws {
        guard !apiKey.isEmpty else {
            throw AppError.apiKeyMissing
        }

        let resolvedURL: URL
        if let baseURL {
            resolvedURL = baseURL
        } else if let defaultURL = URL(string: "https://api.x.ai/v1") {
            resolvedURL = defaultURL
        } else {
            throw AppError.configurationMissing("xAI base URL")
        }

        self.apiKey = apiKey
        self.model = model
        self.baseURL = resolvedURL
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    /// Convenience that never throws for the common case (valid key + default endpoint).
    static func make(apiKey: String, model: String = "grok-3") -> GrokAIProvider? {
        try? GrokAIProvider(apiKey: apiKey, model: model)
    }

    var isAvailable: Bool {
        !apiKey.isEmpty
    }

    func complete(_ request: AIRequest) async throws -> AIResponse {
        guard isAvailable else {
            throw AppError.apiKeyMissing
        }

        let endpoint = baseURL.appendingPathComponent("chat/completions")
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 60

        var messages: [GrokAPI.ChatRequest.Message] = []
        if let system = request.systemPrompt, !system.isEmpty {
            messages.append(.init(role: "system", content: system))
        }
        messages.append(.init(role: "user", content: request.prompt))

        let body = GrokAPI.ChatRequest(
            model: model,
            messages: messages,
            temperature: request.temperature,
            max_tokens: request.maxTokens,
            stream: false
        )

        urlRequest.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw AppError.networkUnavailable
        }

        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw AppError.aiRequestFailed("Grok API error \(http.statusCode): \(message.prefix(200))")
        }

        let decoded: GrokAPI.ChatResponse
        do {
            decoded = try decoder.decode(GrokAPI.ChatResponse.self, from: data)
        } catch {
            throw AppError.aiRequestFailed("Failed to decode Grok response: \(error.localizedDescription)")
        }

        guard let first = decoded.choices.first else {
            throw AppError.aiRequestFailed("Grok response contained no choices")
        }

        let finishReason: AIResponse.FinishReason
        switch first.finish_reason {
        case "length": finishReason = .length
        case "stop", .none: finishReason = .stop
        default: finishReason = .stop
        }

        let usage: AIResponse.Usage?
        if let u = decoded.usage {
            usage = .init(
                promptTokens: u.prompt_tokens ?? 0,
                completionTokens: u.completion_tokens ?? 0
            )
        } else {
            usage = nil
        }

        return AIResponse(
            requestID: request.id,
            content: first.message.content,
            finishReason: finishReason,
            usage: usage
        )
    }
}
