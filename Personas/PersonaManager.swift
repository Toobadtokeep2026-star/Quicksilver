import Foundation
import Observation
import Core

/// Owns persona lifecycle and switching.
/// Conforms to Core.PersonaEngine so other modules depend only on the contract.
@MainActor
@Observable
public final class PersonaManager: PersonaEngine {
    public private(set) var state: PersonaState

    private let eventBus: EventBus
    private let logger: LoggerService
    private let available: [PersonaConfiguration]
    private let policy: PersonaDecisionPolicy

    private var latestFocusName: String?
    private var latestTimePeriod: EventBus.TimePeriod?
    private var latestBatteryLevel: Double?
    private var latestIsLowPower: Bool = false
    private var latestThermalState: String?

    private var latestTaskDescription: String?
    private var latestTaskKind: TaskKind?
    private var latestQueryIntent: QueryIntent?
    private var latestMemoryHints: [String] = []

    private var subscriptionID: UUID?

    public init(
        initial: PersonaConfiguration = .quicksilver,
        available: [PersonaConfiguration] = PersonaConfiguration.all,
        eventBus: EventBus,
        logger: LoggerService,
        policy: PersonaDecisionPolicy = PersonaDecisionPolicy()
    ) {
        self.state = PersonaState(configuration: initial)
        self.available = available
        self.eventBus = eventBus
        self.logger = logger
        self.policy = policy

        Task { @MainActor in
            let id = await eventBus.subscribe { [weak self] event in
                Task { @MainActor in
                    self?.handle(event: event)
                }
            }
            self.subscriptionID = id
        }
    }

    deinit {
        if let id = subscriptionID {
            Task { await eventBus.unsubscribe(id) }
        }
    }

    public var activePersonaID: String {
        state.configuration.id
    }

    public var activeConfiguration: PersonaConfiguration {
        state.configuration
    }

    public var availableConfigurations: [PersonaConfiguration] {
        available
    }

    public var activeMemoryPolicy: MemoryPolicy {
        MemoryPolicy.policy(for: activePersonaID)
    }

    public func switchTo(id: String) async throws {
        guard let config = available.first(where: { $0.id == id }) else {
            throw AppError.personaUnavailable(id)
        }
        try await performSwitch(to: config, reason: "explicit override")
    }

    public func switchTo(_ config: PersonaConfiguration) async throws {
        try await switchTo(id: config.id)
    }

    public func recordInteraction() {
        state.recordInteraction()
    }

    public func updateTaskContext(
        description: String? = nil,
        kind: TaskKind? = nil,
        queryIntent: QueryIntent? = nil,
        memoryHints: [String]? = nil
    ) {
        if let description { latestTaskDescription = description }
        if let kind { latestTaskKind = kind }
        if let queryIntent { latestQueryIntent = queryIntent }
        if let memoryHints { latestMemoryHints = memoryHints }
        evaluateAutonomy(reason: "task context updated")
    }

    private func handle(event: EventBus.Event) {
        switch event {
        case .focusDidChange(let name):
            latestFocusName = name
            evaluateAutonomy(reason: "focus changed")
        case .timeContextDidChange(let period):
            latestTimePeriod = period
            evaluateAutonomy(reason: "time context changed")
        case .batteryPressureChanged(let level, let isLowPower):
            latestBatteryLevel = level
            latestIsLowPower = isLowPower
            evaluateAutonomy(reason: "battery pressure")
        case .thermalPressureChanged(let thermal):
            latestThermalState = thermal
            evaluateAutonomy(reason: "thermal pressure")
        default:
            break
        }
    }

    private func evaluateAutonomy(reason: String) {
        let context = PersonaContext(
            taskDescription: latestTaskDescription,
            taskKind: latestTaskKind,
            queryIntent: latestQueryIntent,
            recentMemoryHints: latestMemoryHints,
            sessionDuration: nil,
            focusName: latestFocusName,
            timePeriod: latestTimePeriod,
            batteryLevel: latestBatteryLevel,
            isLowPower: latestIsLowPower,
            thermalState: latestThermalState
        )

        guard let preferred = policy.preferredPersona(
            current: state.configuration,
            lastSwitchedAt: state.lastSwitchedAt,
            context: context
        ) else { return }

        Task {
            try? await performSwitch(to: preferred, reason: "autonomous (\(reason))")
        }
    }

    private func performSwitch(to config: PersonaConfiguration, reason: String) async throws {
        guard config.id != state.id else { return }

        var newState = PersonaState(configuration: config)
        newState.lastSwitchedAt = Date()
        state = newState

        logger.info("Switched persona to \(config.displayName) [\(reason)]", category: logger.persona)
        await eventBus.publish(.personaDidChange(personaID: config.id))
    }
}
