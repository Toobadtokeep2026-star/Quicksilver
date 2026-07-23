import Foundation
import Core

/// Snapshot of everything the decision policy needs to choose a persona.
/// Designed to grow: task, goal, recent memory, query intent, etc.
/// All fields are optional so callers can supply only what they know.
public struct PersonaContext: Sendable, Equatable {

    // MARK: - Task / Intent (highest value)

    /// Short description of the current task or goal ("architecture review", "debug crash", "reflect on week").
    public var taskDescription: String?

    /// Coarse category of the work in front of the system.
    public var taskKind: TaskKind?

    /// Nature of an incoming user query (when one exists).
    public var queryIntent: QueryIntent?

    // MARK: - Continuity

    /// IDs or short summaries of recent memory items that are relevant.
    public var recentMemoryHints: [String]

    /// How long the current session or conversation has been running.
    public var sessionDuration: TimeInterval?

    // MARK: - Environmental (fallback)

    public var focusName: String?
    public var timePeriod: EventBus.TimePeriod?
    public var batteryLevel: Double?
    public var isLowPower: Bool
    public var thermalState: String?

    public init(
        taskDescription: String? = nil,
        taskKind: TaskKind? = nil,
        queryIntent: QueryIntent? = nil,
        recentMemoryHints: [String] = [],
        sessionDuration: TimeInterval? = nil,
        focusName: String? = nil,
        timePeriod: EventBus.TimePeriod? = nil,
        batteryLevel: Double? = nil,
        isLowPower: Bool = false,
        thermalState: String? = nil
    ) {
        self.taskDescription = taskDescription
        self.taskKind = taskKind
        self.queryIntent = queryIntent
        self.recentMemoryHints = recentMemoryHints
        self.sessionDuration = sessionDuration
        self.focusName = focusName
        self.timePeriod = timePeriod
        self.batteryLevel = batteryLevel
        self.isLowPower = isLowPower
        self.thermalState = thermalState
    }
}

// MARK: - Supporting enums

public enum TaskKind: String, Sendable, Equatable {
    case building          // architecture, implementation, precision work
    case exploring         // research, ideation, open-ended
    case reflecting        // review, continuity, long-horizon
    case debugging         // diagnosis, error analysis
    case communicating     // writing, explaining, teaching
    case unknown
}

public enum QueryIntent: String, Sendable, Equatable {
    case preciseTechnical
    case strategic
    case reflective
    case creative
    case diagnostic
    case unknown
}
