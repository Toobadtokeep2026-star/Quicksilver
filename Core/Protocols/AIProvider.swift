import Foundation

/// Contract for any language-model backend.
/// Lives in Core so every module can depend on the abstraction without importing Services.
public protocol AIProvider: Sendable {
    var id: String { get }
    var displayName: String { get }
    var isAvailable: Bool { get }
    func complete(_ request: AIRequest) async throws -> AIResponse
}
