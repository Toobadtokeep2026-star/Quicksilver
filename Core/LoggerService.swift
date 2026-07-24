import Foundation
import os.log

/// Injectable logging service.
public final class LoggerService: @unchecked Sendable {
    private let subsystem: String

    public let general: Logger
    public let nexus: Logger
    public let persona: Logger
    public let memory: Logger
    public let ai: Logger
    public let ui: Logger

    public init(subsystem: String = "com.quicksilver.app") {
        self.subsystem = subsystem
        self.general = Logger(subsystem: subsystem, category: "General")
        self.nexus = Logger(subsystem: subsystem, category: "Nexus")
        self.persona = Logger(subsystem: subsystem, category: "Persona")
        self.memory = Logger(subsystem: subsystem, category: "Memory")
        self.ai = Logger(subsystem: subsystem, category: "AI")
        self.ui = Logger(subsystem: subsystem, category: "UI")
    }

    public func debug(_ message: String, category: Logger? = nil) {
        (category ?? general).debug("\(message, privacy: .public)")
    }

    public func info(_ message: String, category: Logger? = nil) {
        (category ?? general).info("\(message, privacy: .public)")
    }

    public func error(_ message: String, category: Logger? = nil) {
        (category ?? general).error("\(message, privacy: .public)")
    }

    public static func redact(_ value: String?, maxVisible: Int = 4) -> String {
        guard let value, !value.isEmpty else { return "<empty>" }
        if value.count > 20 || value.lowercased().contains("key") || value.hasPrefix("xai-") || value.hasPrefix("sk-") {
            return "<redacted len=\(value.count)>"
        }
        if value.count <= maxVisible {
            return String(repeating: "*", count: value.count)
        }
        let prefix = value.prefix(maxVisible)
        return "\(prefix)…<redacted>"
    }
}
