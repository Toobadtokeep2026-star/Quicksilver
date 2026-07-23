import Foundation

struct DiagnosticEvent: Identifiable, Sendable, Equatable {
    let id: UUID
    let signalID: UUID?
    let title: String
    let detail: String
    let severity: Severity
    let timestamp: Date
    let source: Signal.Source

    enum Severity: String, Sendable, CaseIterable {
        case info, notice, warning, critical
    }

    init(id: UUID = UUID(), signalID: UUID? = nil, title: String, detail: String, severity: Severity = .info, timestamp: Date = Date(), source: Signal.Source) {
        self.id = id
        self.signalID = signalID
        self.title = title
        self.detail = detail
        self.severity = severity
        self.timestamp = timestamp
        self.source = source
    }
}
