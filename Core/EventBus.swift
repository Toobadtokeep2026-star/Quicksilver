import Foundation

/// Lightweight in-process event bus.
public actor EventBus {
    public enum Event: Sendable {
        case personaDidChange(personaID: String)
        case memoryDidUpdate(itemID: String)
        case featureFlagDidChange(key: String, enabled: Bool)
        case aiRequestStarted(requestID: String)
        case aiRequestCompleted(requestID: String)
        case signalReceived(source: String, value: String, numericValue: Double?)
        case focusDidChange(focusName: String?)
        case timeContextDidChange(period: TimePeriod)
        case batteryPressureChanged(level: Double, isLowPower: Bool)
        case thermalPressureChanged(state: String)
        case networkConditionChanged(isConnected: Bool, isConstrained: Bool)
        case custom(name: String, payload: [String: String])
    }

    public enum TimePeriod: String, Sendable {
        case earlyMorning
        case morning
        case afternoon
        case evening
        case night
    }

    private var subscribers: [UUID: @Sendable (Event) -> Void] = [:]

    public init() {}

    public func subscribe(_ handler: @escaping @Sendable (Event) -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = handler
        return id
    }

    public func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    /// Fans events out asynchronously so a slow subscriber cannot block the bus.
    public func publish(_ event: Event) {
        let handlers = Array(subscribers.values)
        for handler in handlers {
            Task.detached(priority: .utility) {
                handler(event)
            }
        }
    }
}
