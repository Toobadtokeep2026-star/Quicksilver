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

    /// - Parameters:
    ///   - apiKey: Must be non-empty. Caller is responsible for loading from Keychain.
    ///   - model: Defaults to a current high-capability Grok model.
    ///   - baseURL: Defaults to the public xAI endpoint.
    init(
        apiKey: String,
        model: String = "grok-3",
        baseURL: URL = URL(string: "https://api.x.ai/v1")!,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
        self.session = session
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

        var messages: [[String: String]] = []
        if let system = request.systemPrompt, !system.isEmpty {
            messages.append(["role": "system", "content": system])
        }
        messages.append(["role": "user", "content": request.prompt])

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": request.temperature,
            "max_tokens": request.maxTokens,
            "stream": false
        ]

        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw AppError.networkUnavailable
        }

        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw AppError.aiRequestFailed("Grok API error \(http.statusCode): \(message.prefix(200))")
        }

        // Minimal parsing — avoid heavy Codable dependency for the first vertical slice
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AppError.aiRequestFailed("Unexpected response shape from Grok API")
        }

        let finishReasonRaw = (first["finish_reason"] as? String) ?? "stop"
        let finishReason: AIResponse.FinishReason
        switch finishReasonRaw {
        case "length": finishReason = .length
        case "stop": finishReason = .stop
        default: finishReason = .stop
        }

        var usage: AIResponse.Usage?
        if let usageDict = json["usage"] as? [String: Any] {
            let prompt = usageDict["prompt_tokens"] as? Int ?? 0
            let completion = usageDict["completion_tokens"] as? Int ?? 0
            usage = .init(promptTokens: prompt, completionTokens: completion)
        }

        return AIResponse(
            requestID: request.id,
            content: content,
            finishReason: finishReason,
            usage: usage
        )
    }
}
