import Foundation

/// Lightweight in-process event bus.
/// Used for loose coupling between Core, Personas, Memory, and future AI layers.
/// Not a replacement for Combine or NotificationCenter for UI; keep it internal.
actor EventBus {
    enum Event: Sendable {
        case personaDidChange(personaID: String)
        case memoryDidUpdate(itemID: String)
        case featureFlagDidChange(key: String, enabled: Bool)
        case aiRequestStarted(requestID: String)
        case aiRequestCompleted(requestID: String)
        case custom(name: String, payload: [String: String])
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
