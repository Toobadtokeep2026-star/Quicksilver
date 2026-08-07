import Foundation
import Observation
import Core
import Personas
import Memory
import ServicesAI
import Nexus

/// Mercury Brain — central intelligence coordinator.
///
/// Responsibilities:
/// - Understand intent
/// - Retrieve context (memory + Nexus signals + persona state)
/// - Decide when to use tools / AI providers
/// - Plan and validate responses
/// - Influence personality behavioral state
/// - Surface insights rather than raw data
///
/// UI never talks to AIService or MemoryManager directly for complex flows.
/// All reasoning routes through the Brain.
@MainActor
@Observable
final class MercuryBrain {

    // MARK: - Dependencies (owned by DependencyContainer)

    private let personaManager: PersonaManager
    private let memoryManager: MemoryManager
    private let aiService: AIService
    private let nexus: NexusCoordinator
    private let eventBus: EventBus
    private let logger: LoggerService

    // MARK: - Personality Behavioral State

    /// Live behavioral dimensions that influence tone, initiative, and style.
    /// These are not prompts — they are runtime state that shapes expression.
    private(set) var personality = PersonalityState()

    // MARK: - Derived Intelligence

    /// Highest-value current insight, already persona-styled where possible.
    private(set) var primaryInsight: String?

    /// Short natural-language status Mercury would speak.
    private(set) var livingStatus: String = "Observing."

    // MARK: - Init

    init(
        personaManager: PersonaManager,
        memoryManager: MemoryManager,
        aiService: AIService,
        nexus: NexusCoordinator,
        eventBus: EventBus,
        logger: LoggerService
    ) {
        self.personaManager = personaManager
        self.memoryManager = memoryManager
        self.aiService = aiService
        self.nexus = nexus
        self.eventBus = eventBus
        self.logger = logger

        // Seed personality from active persona
        personality.applyPersonaBias(personaID: personaManager.activePersonaID)
        refreshLivingStatus()
    }

    // MARK: - Public Surface

    var activePersonaID: String {
        personaManager.activePersonaID
    }

    var activeConfiguration: PersonaConfiguration {
        personaManager.activeConfiguration
    }

    /// Primary entry for natural language queries (UI + Intents).
    func ask(_ query: String) async throws -> String {
        personaManager.recordInteraction()
        personality.noteInteraction()

        // Classify intent lightly for task context
        let lower = query.lowercased()
        let (intent, kind) = classify(query: lower)

        personaManager.updateTaskContext(
            description: query,
            kind: kind,
            queryIntent: intent
        )

        // Bias personality toward the moment
        personality.adjustFor(intent: intent, kind: kind)

        let config = personaManager.activeConfiguration
        let system = buildSystemPrompt(for: config)

        let response = try await aiService.complete(
            prompt: query,
            systemPrompt: system,
            temperature: config.preferredTemperature,
            maxTokens: config.maxTokensHint
        )

        // Light post-processing for personality color
        let colored = personality.colorResponse(response.content, personaID: config.id)

        refreshLivingStatus()
        return colored
    }

    /// Force a persona switch and update behavioral bias.
    func switchPersona(to id: String) async throws {
        try await personaManager.switchTo(id: id)
        personality.applyPersonaBias(personaID: id)
        nexus.updatePersonaContext(id)
        refreshLivingStatus()
        logger.info("Mercury Brain: persona → \(id)", category: logger.persona)
    }

    /// Capture a memory through the Brain (adds context automatically).
    func remember(_ content: String) async {
        let truncated = String(content.prefix(500))
        let personaID = personaManager.activePersonaID
        let policy = personaManager.activeMemoryPolicy

        personaManager.updateTaskContext(
            description: "Capture memory: \(String(truncated.prefix(80)))",
            kind: .reflecting,
            queryIntent: .reflective,
            memoryHints: [String(truncated.prefix(120))]
        )

        await memoryManager.set(
            key: "note.brain.\(UUID().uuidString.prefix(8))",
            value: truncated,
            category: .temporary,
            metadata: ["source": "mercury-brain", "persona": personaID],
            importanceBoost: policy.writeImportanceHint,
            personaScope: personaID
        )

        personality.noteInsight()
        refreshLivingStatus()
    }

    /// Refresh derived living status from Nexus + personality.
    func refreshLivingStatus() {
        let state = nexus.state
        let persona = personaManager.activeConfiguration.displayName

        if let insight = state.recentInsights.first {
            primaryInsight = insight.title
            livingStatus = "\(persona): \(insight.title)"
        } else if state.overallHealthScore < 50 {
            livingStatus = "\(persona) is watching system pressure. Health \(state.overallHealthScore)."
            personality.increase(.skepticism, by: 0.05)
        } else if state.lowPowerMode {
            livingStatus = "\(persona) notes low power. Conserving focus."
            personality.increase(.patience, by: 0.04)
        } else {
            livingStatus = "\(persona) is present. Observing quietly."
        }
    }

    // MARK: - Internals

    private func classify(query: String) -> (QueryIntent, TaskKind) {
        if containsAny(query, ["architect", "implement", "refactor", "debug", "error", "crash", "fix", "structure", "precision", "swift", "xcode"]) {
            return (.preciseTechnical, .building)
        }
        if containsAny(query, ["reflect", "remember", "history", "pattern", "long-term", "why did", "continuity", "archive"]) {
            return (.reflective, .reflecting)
        }
        if containsAny(query, ["idea", "brainstorm", "what if", "explore", "creative", "option", "strategy", "imagine"]) {
            return (.creative, .exploring)
        }
        if containsAny(query, ["diagnose", "why is", "broken", "failing", "battery", "network", "health"]) {
            return (.diagnostic, .debugging)
        }
        return (.strategic, .exploring)
    }

    private func buildSystemPrompt(for config: PersonaConfiguration) -> String {
        var prompt = config.systemPrompt

        // Inject live behavioral guidance
        let bias = personality.promptBias()
        if !bias.isEmpty {
            prompt += "\n\nCurrent behavioral posture: \(bias)"
        }

        // Inject light Nexus context for awareness
        let health = nexus.state.overallHealthScore
        let battery = nexus.state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "unknown"
        prompt += "\n\nDevice context (private, for awareness only): health \(health), battery \(battery)."

        return prompt
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
