import Foundation
import Observation
import Core
import Personas
import Memory
import ServicesAI
import Nexus

/// Mercury Brain — central intelligence coordinator.
///
/// Invisible Architecture: UI and Intents never select engines, providers,
/// or memory strategies. The Brain decides.
///
/// Responsibilities:
/// - Understand intent
/// - Retrieve context (memory + Nexus signals + persona state)
/// - Decide when to use tools / AI providers
/// - Plan and validate responses
/// - Influence personality behavioral state
/// - Surface insights rather than raw data
/// - Determine which chamber (Forge / Eternal / Sanctum) should awaken
@MainActor
@Observable
final class MercuryBrain {

    private let personaManager: PersonaManager
    private let memoryManager: MemoryManager
    private let aiService: AIService
    private let nexus: NexusCoordinator
    private let eventBus: EventBus
    private let logger: LoggerService

    private(set) var personality = PersonalityState()
    private(set) var primaryInsight: String?
    private(set) var livingStatus: String = "Quicksilver is present. Observing."
    private(set) var suggestedChamber: SanctumChamber = .sanctum

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

        personality.applyPersonaBias(personaID: personaManager.activePersonaID)
        refreshLivingStatus()
    }

    var activePersonaID: String { personaManager.activePersonaID }
    var activeConfiguration: PersonaConfiguration { personaManager.activeConfiguration }

    /// Primary entry for natural language. All conversation should come through here.
    /// The Brain owns context assembly so UI cannot accidentally bypass memory,
    /// persona state, or Nexus signals.
    func ask(_ query: String) async throws -> String {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            throw AppError.aiRequestFailed("Mercury received an empty request")
        }

        personaManager.recordInteraction()
        personality.noteInteraction()

        let lower = trimmedQuery.lowercased()
        let (intent, kind) = classify(query: lower)

        personaManager.updateTaskContext(
            description: trimmedQuery,
            kind: kind,
            queryIntent: intent
        )

        personality.adjustFor(intent: intent, kind: kind)
        suggestedChamber = chamberFor(intent: intent, kind: kind, personaID: activePersonaID)

        let config = personaManager.activeConfiguration
        let context = makeAIContext(for: trimmedQuery, persona: config)

        let response = try await aiService.complete(
            userMessage: trimmedQuery,
            personaSystemPrompt: buildSystemPrompt(for: config),
            preferredTemperature: config.preferredTemperature,
            maxTokensHint: config.maxTokensHint,
            context: context
        )

        let colored = personality.colorResponse(response.content, personaID: config.id)
        refreshLivingStatus()
        return colored
    }

    func switchPersona(to id: String) async throws {
        try await personaManager.switchTo(id: id)
        personality.applyPersonaBias(personaID: id)
        nexus.updatePersonaContext(id)
        suggestedChamber = chamberForPersona(id)
        refreshLivingStatus()
        logger.info("Mercury Brain: persona → \(id)", category: logger.persona)
    }

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

    func refreshLivingStatus() {
        let state = nexus.state
        let persona = personaManager.activeConfiguration.displayName

        if let insight = state.recentInsights.first {
            primaryInsight = insight.title
            livingStatus = "\(persona): \(insight.title)"
        } else if state.overallHealthScore < 50 {
            livingStatus = "\(persona) watches rising pressure. Health \(state.overallHealthScore)."
            personality.increase(.skepticism, by: 0.04)
        } else if state.lowPowerMode {
            livingStatus = "\(persona) notes low power. Conserving."
            personality.increase(.patience, by: 0.03)
        } else {
            livingStatus = "\(persona) is present. The Sanctum holds."
        }
    }

    // MARK: - Context

    private func makeAIContext(
        for query: String,
        persona: PersonaConfiguration
    ) -> ContextAssembler.Input {
        let memory = relevantMemorySnippets(for: query, personaID: persona.id)
        let insights = nexus.state.recentInsights.prefix(3).map(\.title)
        let device = "health \(nexus.state.overallHealthScore), battery \(batteryDescription)"

        return ContextAssembler.Input(
            personaID: persona.id,
            personaDisplayName: persona.displayName,
            recentMemorySnippets: memory,
            latestInsightTitles: Array(insights),
            deviceSummary: device
        )
    }

    private func relevantMemorySnippets(for query: String, personaID: String) -> [String] {
        let words = Set(
            query
                .lowercased()
                .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
                .filter { $0.count >= 3 }
                .map(String.init)
        )

        return memoryManager.items(forPersona: personaID)
            .filter { $0.category != .temporary || $0.importance >= 0.7 }
            .map { item in
                let haystack = "\(item.key) \(item.value)".lowercased()
                let score = words.reduce(into: 0) { total, word in
                    if haystack.contains(word) { total += 1 }
                }
                return (item, score)
            }
            .sorted {
                if $0.1 != $1.1 { return $0.1 > $1.1 }
                return $0.0.importance > $1.0.importance
            }
            .prefix(5)
            .map { "\($0.0.value)" }
    }

    private var batteryDescription: String {
        guard let level = nexus.state.batteryLevel else { return "unknown" }
        return "\(Int(level * 100))%"
    }

    // MARK: - Internals

    private func classify(query: String) -> (QueryIntent, TaskKind) {
        if containsAny(query, ["architect", "implement", "refactor", "debug", "error", "crash", "fix", "structure", "precision", "swift", "xcode", "spm", "git", "commit", "pr ", "pull request"]) {
            return (.preciseTechnical, .building)
        }
        if containsAny(query, ["reflect", "remember", "history", "pattern", "long-term", "why did", "continuity", "archive", "memory"]) {
            return (.reflective, .reflecting)
        }
        if containsAny(query, ["idea", "brainstorm", "what if", "explore", "creative", "option", "strategy", "imagine"]) {
            return (.creative, .exploring)
        }
        if containsAny(query, ["diagnose", "why is", "broken", "failing", "battery", "network", "health", "thermal"]) {
            return (.diagnostic, .debugging)
        }
        return (.strategic, .exploring)
    }

    private func chamberFor(intent: QueryIntent, kind: TaskKind, personaID: String) -> SanctumChamber {
        if personaID == "forge" || intent == .preciseTechnical || kind == .building || kind == .debugging {
            return .forge
        }
        if personaID == "eternal" || intent == .reflective || intent == .diagnostic || kind == .reflecting {
            return .eternal
        }
        return .sanctum
    }

    private func chamberForPersona(_ id: String) -> SanctumChamber {
        switch id.lowercased() {
        case "forge": return .forge
        case "eternal": return .eternal
        default: return .sanctum
        }
    }

    private func buildSystemPrompt(for config: PersonaConfiguration) -> String {
        var prompt = config.systemPrompt

        let bias = personality.promptBias()
        if !bias.isEmpty {
            prompt += "\n\nBehavioral posture (internal): \(bias)"
        }

        prompt += """


Core stance:
- Truth is more important than agreement.
- Challenge unsupported conclusions with precision.
- Critique ideas, never the person.
- Admit uncertainty when evidence is incomplete.
- Prefer the smallest verifiable next step over speculation.
- Dry, elegant wit is allowed; cruelty is not.
- Everything ultimately serves the user's long-term success.
"""

        let health = nexus.state.overallHealthScore
        prompt += "\n\nDevice context (private): health \(health), battery \(batteryDescription)."

        return prompt
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
