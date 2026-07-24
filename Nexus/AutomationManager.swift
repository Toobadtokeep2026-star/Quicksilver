import Foundation
import Core

/// DEPRECATED — Do not use.
/// Real automation is provided by `AutomationBridge` and the App Intents in `QuicksilverIntents`.
/// This placeholder remains only to avoid breaking residual references.
@available(*, deprecated, message: "Use AutomationBridge and QuicksilverIntents instead")
final class AutomationManager: @unchecked Sendable {
    private var isConfigured = false

    func configure() {
        isConfigured = true
    }

    func trigger(named name: String) throws {
        guard isConfigured else { throw AppError.nexusNotReady }
        throw AppError.unsupportedFeature("Use AutomationBridge.triggerDiagnostic instead")
    }
}
