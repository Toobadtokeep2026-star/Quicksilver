import Foundation

/// Lightweight in-process event bus.
/// Used for loose coupling between Core, Personas, Memory, Nexus, and future AI layers.
actor EventBus {
    enum Event: Sendable {
        // Persona lifecycle
        case personaDidChange(personaID: String)

        // Memory
        case memoryDidUpdate(itemID: String)

        // Feature flags
        case featureFlagDidChange(key: String, enabled: Bool)

        // AI lifecycle
        case aiRequestStarted(requestID: String)
        case aiRequestCompleted(requestID: String)

        // Autonomy signals (published by Nexus or system bridges)
        case focusDidChange(focusName: String?)
        case timeContextDidChange(period: TimePeriod)
        case batteryPressureChanged(level: Double, isLowPower: Bool)
        case thermalPressureChanged(state: String)
        case networkConditionChanged(isConnected: Bool, isConstrained: Bool)

        // Generic escape hatch
        case custom(name: String, payload: [String: String])
    }

    /// Coarse time-of-day periods used by autonomous policies.
    enum TimePeriod: String, Sendable {
        case earlyMorning   // 05–08
        case morning        // 08–12
        case afternoon      // 12–17
        case evening        // 17–21
        case night          // 21–05
    }

    private var subscribers: [UUID: (Event) -> Void] = [:]

    func subscribe(_ handler: @escaping @Sendable (Event) -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = handler
        return id
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    func publish(_ event: Event) {
        for handler in subscribers.values {
            handler(event)
        }
    }
}
