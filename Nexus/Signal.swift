import Foundation

/// Unified signal representation for the Nexus awareness layer.
struct Signal: Identifiable, Sendable, Equatable {
    let id: UUID
    let source: Source
    let category: Category
    let timestamp: Date
    let value: String
    let numericValue: Double?
    let confidence: Double
    let metadata: [String: String]

    enum Source: String, Sendable, Codable, CaseIterable {
        case network, battery, storage, device, lifecycle, user, system
    }

    enum Category: String, Sendable, Codable, CaseIterable {
        case connectivity, power, capacity, performance, environment, diagnostic
    }

    init(id: UUID = UUID(), source: Source, category: Category, timestamp: Date = Date(), value: String, numericValue: Double? = nil, confidence: Double = 1.0, metadata: [String: String] = [:]) {
        self.id = id
        self.source = source
        self.category = category
        self.timestamp = timestamp
        self.value = value
        self.numericValue = numericValue
        self.confidence = min(max(confidence, 0), 1)
        self.metadata = metadata
    }
}
