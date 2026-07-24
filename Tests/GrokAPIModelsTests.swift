import XCTest
@testable import ServicesAI

final class GrokAPIModelsTests: XCTestCase {
    func testChatResponseDecoding() throws {
        let json = """
        {
          "id": "chatcmpl-test",
          "choices": [{"message": {"role": "assistant", "content": "Forge ready."}, "finish_reason": "stop"}],
          "usage": {"prompt_tokens": 12, "completion_tokens": 4, "total_tokens": 16}
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(GrokAPI.ChatResponse.self, from: json)
        XCTAssertEqual(decoded.choices.count, 1)
        XCTAssertEqual(decoded.choices[0].message.content, "Forge ready.")
        XCTAssertEqual(decoded.usage?.prompt_tokens, 12)
    }

    func testGrokMakeFactory() {
        XCTAssertNil(GrokAIProvider.make(apiKey: ""))
        XCTAssertNotNil(GrokAIProvider.make(apiKey: "xai-test"))
    }
}
