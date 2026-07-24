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

    private var subscribers: [UUID: (Event) -> Void] = [:]

    public init() {}

    public func subscribe(_ handler: @escaping @Sendable (Event) -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = handler
        return id
    }

    public func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    public func publish(_ event: Event) {
        for handler in subscribers.values {
            handler(event)
        }
    }
}
