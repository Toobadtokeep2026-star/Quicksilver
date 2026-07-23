import Foundation
import Core

/// Future home for Shortcuts, App Intents, and background automation.
/// Day One: empty surface with clear extension points.
/// Do not claim Siri or Shortcuts capabilities until the App Intents and App Shortcuts are implemented and declared.
final class AutomationManager: @unchecked Sendable {
    private var isConfigured = false

    func configure() {
        // Future:
        // - Register AppShortcutsProvider
        // - Define AppIntent types for common Quicksilver actions
        // - Handle background URL sessions or BGTaskScheduler if needed
        isConfigured = true
        QuicksilverLogger.info("AutomationManager configured (placeholder)", category: .nexus)
    }

    /// Placeholder for triggering a named automation.
    /// Will throw AppError.unsupportedFeature until real intents exist.
    func trigger(named name: String) throws {
        guard isConfigured else {
            throw AppError.nexusNotReady
        }
        throw AppError.unsupportedFeature("Automation '\(name)' is not yet implemented")
    }
}
