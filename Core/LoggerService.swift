import Foundation
import os.log

/// Injectable logging service.
/// Replaces the pure static QuicksilverLogger for better testability
/// while preserving the same category-based OSLog surface.
final class LoggerService: @unchecked Sendable {
    private let subsystem: String

    let general: Logger
    let nexus: Logger
    let persona: Logger
    let memory: Logger
    let ai: Logger
    let ui: Logger

    init(subsystem: String = "com.quicksilver.app") {
        self.subsystem = subsystem
        self.general = Logger(subsystem: subsystem, category: "General")
        self.nexus = Logger(subsystem: subsystem, category: "Nexus")
        self.persona = Logger(subsystem: subsystem, category: "Persona")
        self.memory = Logger(subsystem: subsystem, category: "Memory")
        self.ai = Logger(subsystem: subsystem, category: "AI")
        self.ui = Logger(subsystem: subsystem, category: "UI")
    }

    func debug(_ message: String, category: Logger? = nil) {
        (category ?? general).debug("\(message, privacy: .public)")
    }

    func info(_ message: String, category: Logger? = nil) {
        (category ?? general).info("\(message, privacy: .public)")
    }

    func error(_ message: String, category: Logger? = nil) {
        (category ?? general).error("\(message, privacy: .public)")
    }
}
