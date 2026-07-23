import Foundation

final class AutomationBridge: @unchecked Sendable {
    enum Capability: String, CaseIterable {
        case runDiagnostic, reportNetworkStatus, reportBatteryStatus, openNexus
    }

    private(set) var isConfigured = false

    func configure() {
        isConfigured = true
    }

    func triggerDiagnostic(named name: String) throws {
        guard isConfigured else { throw AppError.nexusNotReady }
        throw AppError.unsupportedFeature("Automation '\(name)' requires App Intents registration (future milestone)")
    }

    var availableCapabilities: [Capability] { Capability.allCases }
}
