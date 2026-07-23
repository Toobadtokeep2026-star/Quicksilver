import Foundation

struct NexusState: Sendable, Equatable {
    var isActive: Bool = false
    var lastUpdated: Date = Date()
    var networkStatus: String = "unknown"
    var isNetworkExpensive: Bool = false
    var isNetworkConstrained: Bool = false
    var batteryLevel: Double? = nil
    var batteryState: String = "unknown"
    var availableStorageGB: Double? = nil
    var totalStorageGB: Double? = nil
    var thermalState: String = "unknown"
    var lowPowerMode: Bool = false
    var recentSignals: [Signal] = []
    var recentEvents: [DiagnosticEvent] = []
    var recentInsights: [Insight] = []
    var networkHealthScore: Int = 100
    var powerHealthScore: Int = 100
    var overallHealthScore: Int = 100

    mutating func appendSignal(_ signal: Signal, maxHistory: Int = 50) {
        recentSignals.insert(signal, at: 0)
        if recentSignals.count > maxHistory { recentSignals = Array(recentSignals.prefix(maxHistory)) }
        lastUpdated = Date()
    }

    mutating func appendEvent(_ event: DiagnosticEvent, maxHistory: Int = 30) {
        recentEvents.insert(event, at: 0)
        if recentEvents.count > maxHistory { recentEvents = Array(recentEvents.prefix(maxHistory)) }
        lastUpdated = Date()
    }

    mutating func appendInsight(_ insight: Insight, maxHistory: Int = 20) {
        recentInsights.insert(insight, at: 0)
        if recentInsights.count > maxHistory { recentInsights = Array(recentInsights.prefix(maxHistory)) }
        lastUpdated = Date()
    }
}

struct Insight: Identifiable, Sendable, Equatable {
    let id: UUID
    let title: String
    let body: String
    let severity: DiagnosticEvent.Severity
    let relatedSignalIDs: [UUID]
    let personaStyle: String
    let timestamp: Date
    let suggestedAction: String?

    init(id: UUID = UUID(), title: String, body: String, severity: DiagnosticEvent.Severity = .info, relatedSignalIDs: [UUID] = [], personaStyle: String, timestamp: Date = Date(), suggestedAction: String? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.severity = severity
        self.relatedSignalIDs = relatedSignalIDs
        self.personaStyle = personaStyle
        self.timestamp = timestamp
        self.suggestedAction = suggestedAction
    }
}
