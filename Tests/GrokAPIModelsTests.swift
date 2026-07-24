import XCTest
@testable import ServicesAI

final class GrokAPIModelsTests: XCTestCase {

    func testChatResponseDecoding() throws {
        let json = """
        {
          "id": "chatcmpl-test",
          "choices": [
            {
              "message": { "role": "assistant", "content": "Forge ready." },
              "finish_reason": "stop"
            }
          ],
          "usage": {
            "prompt_tokens": 12,
            "completion_tokens": 4,
            "total_tokens": 16
          }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(GrokAPI.ChatResponse.self, from: json)
        XCTAssertEqual(decoded.choices.count, 1)
        XCTAssertEqual(decoded.choices[0].message.content, "Forge ready.")
        XCTAssertEqual(decoded.choices[0].finish_reason, "stop")
        XCTAssertEqual(decoded.usage?.prompt_tokens, 12)
        XCTAssertEqual(decoded.usage?.completion_tokens, 4)
    }

    func testChatResponseMissingChoicesThrows() {
        let json = """
        { "id": "x", "choices": [] }
        """.data(using: .utf8)!

        let decoded = try? JSONDecoder().decode(GrokAPI.ChatResponse.self, from: json)
        XCTAssertNotNil(decoded)
        XCTAssertTrue(decoded?.choices.isEmpty == true)
    }

    func testChatRequestEncoding() throws {
        let request = GrokAPI.ChatRequest(
            model: "grok-3",
            messages: [
                .init(role: "system", content: "You are Forge."),
                .init(role: "user", content: "Status?")
            ],
            temperature: 0.3,
            max_tokens: 256,
            stream: false
        )

        let data = try JSONEncoder().encode(request)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(obj?["model"] as? String, "grok-3")
        XCTAssertEqual(obj?["temperature"] as? Double, 0.3)
        XCTAssertEqual(obj?["stream"] as? Bool, false)
        let messages = obj?["messages"] as? [[String: String]]
        XCTAssertEqual(messages?.count, 2)
    }
}
