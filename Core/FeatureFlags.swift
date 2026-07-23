import Foundation
import Combine

/// Central feature flag surface.
/// Day Two: in-memory + simple UserDefaults persistence.
/// Future: remote config without locking the app to a specific backend.
@MainActor
final class FeatureFlags: ObservableObject {
    @Published private(set) var flags: [String: Bool]

    private let defaults: UserDefaults
    private let storageKey = "quicksilver.featureFlags"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.dictionary(forKey: storageKey) as? [String: Bool] {
            self.flags = saved
        } else {
            self.flags = Self.defaultFlags
        }
    }

    private static let defaultFlags: [String: Bool] = [
        "personaSwitching": true,
        "memoryPersistence": true,
        "aiServiceEnabled": false,
        "nexusDetailedMetrics": false,
        "experimentalEventBus": true
    ]

    func isEnabled(_ key: String) -> Bool {
        flags[key] ?? false
    }

    func set(_ key: String, enabled: Bool) {
        flags[key] = enabled
        defaults.set(flags, forKey: storageKey)
        objectWillChange.send()
    }

    func resetToDefaults() {
        flags = Self.defaultFlags
        defaults.set(flags, forKey: storageKey)
        objectWillChange.send()
    }
}
