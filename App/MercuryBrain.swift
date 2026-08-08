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
/// Sprint advances:
/// Phase 1 — Real memory retrieval + context assembly into every ask
/// Phase 2 — Unified surface for UI + future Intent bridging
/// Phase 3 — LocalIntentClassifier scaffold (on-device ready)
/// Phase 4 — Reactive living status + chamber for presence layer
/// Phase 5 — Personality + memory importance feedback loops
@MainActor
@Observable
final class MercuryBrain {

    private let personaManager: PersonaManager
    private let memoryManager: MemoryManager
    private let aiService: AIService
    private let nexus: NexusCoordinator
    private let eventBus: EventBus
    private let logger: LoggerService
    private let localClassifier = LocalIntentClassifier()

    private(set) var personality = PersonalityState()
    private(set) var primaryInsight: String?
    private(set) var livingStatus: String = "Quicksilver is present. Observing."
    private(set) var suggestedChamber: SanctumChamber = .sanctum
    private(set) var lastContextSummary: String = ""

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

    // MARK: - Primary Surface

    /// Primary entry for natural language. All conversation should come through here.
    func ask(_ query: String) async throws -> String {
        personaManager.recordInteraction()
        personality.noteInteraction()

        let lower = query.lowercased()
        let classification = localClassifier.classify(query: lower)
        let intent = classification.intent
        let kind = classification.kind

        personaManager.updateTaskContext(
            description: query,
            kind: kind,
            queryIntent: intent
        )

        personality.adjustFor(intent: intent, kind: kind)
        suggestedChamber = chamberFor(intent: intent, kind: kind, personaID: activePersonaID)

        // Phase 1: Retrieve relevant memory (persona-scoped + high importance)
        let relevantMemories = retrieveRelevantMemory(for: query, personaID: activePersonaID)
        let memoryBlock = formatMemoryBlock(relevantMemories)

        let config = personaManager.activeConfiguration
        let system = buildSystemPrompt(for: config, memoryBlock: memoryBlock, intent: intent)

        lastContextSummary = "intent=\(intent) kind=\(kind) memories=\(relevantMemories.count) chamber=\(suggestedChamber.rawValue)"

        let response = try await aiService.complete(
            prompt: query,
            systemPrompt: system,
            temperature: config.preferredTemperature,
            maxTokens: config.maxTokensHint
        )

        let colored = personality.colorResponse(response.content, personaID: config.id)

        // Phase 5: Light adaptive feedback — high-signal exchanges raise curiosity/focus
        if relevantMemories.count >= 2 || intent == .preciseTechnical {
            personality.increase(.focus, by: 0.03)
        }

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

    /// Phase 5 scaffold: prune low-importance temporary memories.
    func consolidateMemory(importanceThreshold: Double = 0.25) async -> Int {
        let pruned = await memoryManager.pruneBelow(importance: importanceThreshold)
        if pruned > 0 {
            logger.info("Brain consolidated memory: pruned \(pruned)", category: logger.memory)
            personality.increase(.patience, by: 0.02)
        }
        return pruned
    }

    // MARK: - Living Status & Presence (Phase 4)

    func refreshLivingStatus() {
        let state = nexus.state
        let persona = personaManager.activeConfiguration.displayName

        if let insight = state.recentInsights.first {
            primaryInsight = insight.title
            livingStatus = "\(persona): \(insight.title)"
        } else if state.overallHealthScore < 45 {
            livingStatus = "\(persona) registers rising pressure. Health \(state.overallHealthScore)."
            personality.increase(.skepticism, by: 0.04)
            suggestedChamber = .eternal
        } else if state.lowPowerMode {
            livingStatus = "\(persona) notes low power. Conserving presence."
            personality.increase(.patience, by: 0.03)
        } else if state.overallHealthScore > 85 && state.batteryLevel.map({ $0 > 0.6 }) == true {
            livingStatus = "\(persona) is present. The Sanctum is clear."
            personality.increase(.curiosity, by: 0.02)
        } else {
            livingStatus = "\(persona) is present. The Sanctum holds."
        }
    }

    // MARK: - Memory Retrieval (Phase 1)

    private func retrieveRelevantMemory(for query: String, personaID: String) -> [MemoryItem] {
        // Prefer persona-scoped + higher importance. Keep payload small for prompt budget.
        let queryObj = MemoryQuery(
            personaScope: personaID,
            minimumImportance: 0.35,
            limit: 6
        )
        var items = memoryManager.items(matching: queryObj)

        // Simple relevance boost: prefer items whose value shares tokens with the query
        let tokens = Set(query.lowercased().split(separator: " ").map(String.init).filter { $0.count > 3 })
        if !tokens.isEmpty {
            items.sort { a, b in
                let scoreA = tokens.reduce(0) { $0 + (a.value.lowercased().contains($1) ? 1 : 0) } + a.importance
                let scoreB = tokens.reduce(0) { $0 + (b.value.lowercased().contains($1) ? 1 : 0) } + b.importance
                return scoreA > scoreB
            }
        }

        return Array(items.prefix(5))
    }

    private func formatMemoryBlock(_ items: [MemoryItem]) -> String {
        guard !items.isEmpty else { return "No high-signal prior memory." }
        let lines = items.map { item in
            let scope = item.personaScope ?? "shared"
            return "- [\(item.category.rawValue)/\(scope) imp=\(String(format: "%.2f", item.importance))] \(item.value.prefix(180))"
        }
        return "Relevant memory:\n" + lines.joined(separator: "\n")
    }

    // MARK: - System Prompt Assembly

    private func buildSystemPrompt(
        for config: PersonaConfiguration,
        memoryBlock: String,
        intent: QueryIntent
    ) -> String {
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

        // Device + Nexus context (private)
        let health = nexus.state.overallHealthScore
        let battery = nexus.state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "unknown"
        let thermal = nexus.state.thermalState
        let network = nexus.state.networkStatus
        prompt += "\n\nDevice context (private): health \(health), battery \(battery), thermal \(thermal), network \(network)."

        // Memory injection
        prompt += "\n\n\(memoryBlock)"

        // Intent hint for the model
        prompt += "\n\nCurrent classified intent: \(String(describing: intent)). Respond at the appropriate depth."

        return prompt
    }

    // MARK: - Chamber Logic

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
}

// MARK: - Local Intent Classifier (Phase 3 scaffold)

/// Rule-based classifier with clear extension point for Core ML / Apple Intelligence.
/// Designed so a future on-device model can replace or augment `classify` without
/// changing MercuryBrain call sites.
struct LocalIntentClassifier: Sendable {

    struct Classification: Sendable {
        let intent: QueryIntent
        let kind: TaskKind
        let confidence: Double
    }

    func classify(query: String) -> Classification {
        if containsAny(query, ["architect", "implement", "refactor", "debug", "error", "crash", "fix", "structure", "precision", "swift", "xcode", "spm", "git", "commit", "pr ", "pull request", "code", "compile"]) {
            return Classification(intent: .preciseTechnical, kind: .building, confidence: 0.85)
        }
        if containsAny(query, ["reflect", "remember", "history", "pattern", "long-term", "why did", "continuity", "archive", "memory", "what did we"]) {
            return Classification(intent: .reflective, kind: .reflecting, confidence: 0.8)
        }
        if containsAny(query, ["idea", "brainstorm", "what if", "explore", "creative", "option", "strategy", "imagine", "design"]) {
            return Classification(intent: .creative, kind: .exploring, confidence: 0.75)
        }
        if containsAny(query, ["diagnose", "why is", "broken", "failing", "battery", "network", "health", "thermal", "slow", "hot"]) {
            return Classification(intent: .diagnostic, kind: .debugging, confidence: 0.8)
        }
        return Classification(intent: .strategic, kind: .exploring, confidence: 0.55)
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
