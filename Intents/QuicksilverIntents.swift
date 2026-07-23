import AppIntents
import Foundation
import Core
import Personas

// MARK: - Get Current Persona (primary read surface)

@available(iOS 17.0, macOS 14.0, *)
public struct GetCurrentPersonaIntent: AppIntent {
    public static var title: LocalizedStringResource = "Get Current Persona"
    public static var description = IntentDescription("Returns the persona currently active in Quicksilver (autonomously chosen or overridden).")
    public static var openAppWhenRun: Bool = false

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let manager = IntentDependencies.shared.personaManager else {
            throw AppError.nexusNotReady
        }
        let name = manager.activeConfiguration.displayName
        let id = manager.activeConfiguration.id
        return .result(value: "\(name) (\(id))")
    }
}

// MARK: - Force Persona (explicit override only)

@available(iOS 17.0, macOS 14.0, *)
public struct ForcePersonaIntent: AppIntent {
    public static var title: LocalizedStringResource = "Force Persona"
    public static var description = IntentDescription("Manually override the autonomous persona selection. Use sparingly.")
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Persona", description: "forge, quicksilver, or eternal")
    public var personaID: String

    public init() {}
    public init(personaID: String) {
        self.personaID = personaID
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let manager = IntentDependencies.shared.personaManager else {
            throw AppError.nexusNotReady
        }
        try await manager.switchTo(id: personaID.lowercased())
        return .result(value: "Forced to \(manager.activeConfiguration.displayName)")
    }
}

// MARK: - Capture Memory

@available(iOS 17.0, macOS 14.0, *)
public struct CaptureMemoryIntent: AppIntent {
    public static var title: LocalizedStringResource = "Remember This"
    public static var description = IntentDescription("Capture a short note or thought into Quicksilver Memory.")
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Content")
    public var content: String

    public init() {}
    public init(content: String) {
        self.content = content
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let manager = IntentDependencies.shared.personaManager else {
            throw AppError.nexusNotReady
        }

        // Memory work is continuity-oriented → tilt toward Eternal
        manager.updateTaskContext(
            description: "Capture memory: \(String(content.prefix(80)))",
            kind: .reflecting,
            queryIntent: .reflective,
            memoryHints: [String(content.prefix(120))]
        )

        let truncated = String(content.prefix(500))
        IntentDependencies.shared.logger?.info("Memory capture: \(truncated)", category: IntentDependencies.shared.logger?.memory)
        return .result(value: "Captured: \(truncated)")
    }
}

// MARK: - Get Context

@available(iOS 17.0, macOS 14.0, *)
public struct GetContextIntent: AppIntent {
    public static var title: LocalizedStringResource = "What’s the Context"
    public static var description = IntentDescription("Returns a short summary of current Quicksilver state (persona + health signals).")
    public static var openAppWhenRun: Bool = false

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let manager = IntentDependencies.shared.personaManager,
              let nexus = IntentDependencies.shared.nexusCoordinator else {
            throw AppError.nexusNotReady
        }
        let persona = manager.activeConfiguration.displayName
        let health = nexus.state.overallHealthScore
        let battery = nexus.state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "unknown"
        return .result(value: "Persona: \(persona) | Health: \(health) | Battery: \(battery)")
    }
}

// MARK: - Query Nexus

@available(iOS 17.0, macOS 14.0, *)
public struct QueryNexusIntent: AppIntent {
    public static var title: LocalizedStringResource = "Ask Nexus"
    public static var description = IntentDescription("Send a short query to the Quicksilver intelligence layer.")
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Query")
    public var query: String

    public init() {}
    public init(query: String) {
        self.query = query
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let manager = IntentDependencies.shared.personaManager else {
            throw AppError.nexusNotReady
        }

        // Infer rough intent from the query text so the policy can choose appropriately
        let lower = query.lowercased()
        let intent: QueryIntent
        let kind: TaskKind

        if containsAny(lower, ["architect", "implement", "refactor", "debug", "error", "crash", "fix", "structure", "precision"]) {
            intent = .preciseTechnical
            kind = .building
        } else if containsAny(lower, ["reflect", "remember", "history", "pattern", "long-term", "why did", "continuity"]) {
            intent = .reflective
            kind = .reflecting
        } else if containsAny(lower, ["idea", "brainstorm", "what if", "explore", "creative", "option", "strategy"]) {
            intent = .creative
            kind = .exploring
        } else if containsAny(lower, ["diagnose", "why is", "broken", "failing"]) {
            intent = .diagnostic
            kind = .debugging
        } else {
            intent = .strategic
            kind = .exploring
        }

        manager.updateTaskContext(
            description: query,
            kind: kind,
            queryIntent: intent
        )

        let persona = manager.activeConfiguration.displayName
        // Placeholder — later routes through ServicesAI + persona system prompt
        return .result(value: "[\(persona)] Received: \(query). Full AI path not yet wired.")
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}

// MARK: - App Shortcuts provider

@available(iOS 17.0, macOS 14.0, *)
public struct QuicksilverShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetCurrentPersonaIntent(),
            phrases: [
                "What persona is active in \(.applicationName)",
                "Current persona in \(.applicationName)"
            ],
            shortTitle: "Current Persona",
            systemImageName: "person.crop.circle"
        )
        AppShortcut(
            intent: GetContextIntent(),
            phrases: [
                "What\'s the context in \(.applicationName)",
                "Quicksilver status"
            ],
            shortTitle: "Context",
            systemImageName: "info.circle"
        )
        AppShortcut(
            intent: CaptureMemoryIntent(content: ""),
            phrases: [
                "Remember this in \(.applicationName)",
                "Capture memory in \(.applicationName)"
            ],
            shortTitle: "Remember",
            systemImageName: "brain.head.profile"
        )
        AppShortcut(
            intent: QueryNexusIntent(query: ""),
            phrases: [
                "Ask Nexus",
                "Ask \(.applicationName)"
            ],
            shortTitle: "Ask Nexus",
            systemImageName: "sparkles"
        )
    }
}
