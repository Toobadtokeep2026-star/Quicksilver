import Foundation

struct InsightEngine: Sendable {
    func insight(for signal: Signal, recent: [Signal], personaID: String) -> Insight? {
        switch signal.source {
        case .network: return networkInsight(signal: signal, recent: recent, personaID: personaID)
        case .battery: return batteryInsight(signal: signal, recent: recent, personaID: personaID)
        case .storage: return storageInsight(signal: signal, personaID: personaID)
        case .device: return deviceInsight(signal: signal, personaID: personaID)
        default: return nil
        }
    }

    private func networkInsight(signal: Signal, recent: [Signal], personaID: String) -> Insight? {
        let recentNetwork = recent.filter { $0.source == .network && $0.timestamp > Date().addingTimeInterval(-600) }
        if signal.value == "disconnected" {
            return style(title: "Network lost", body: "The device is currently offline.", severity: .warning, signal: signal, personaID: personaID, action: "Check Wi-Fi or cellular settings.")
        }
        if recentNetwork.count >= 3 {
            return style(title: "Network instability", body: "Connection state changed \(recentNetwork.count) times in the last 10 minutes.", severity: .notice, signal: signal, personaID: personaID, action: "Consider moving closer to the access point or toggling Airplane Mode.")
        }
        if signal.value == "constrained" || signal.value == "expensive" {
            return style(title: "Constrained network", body: "The current path is marked \(signal.value). Background data may be limited.", severity: .notice, signal: signal, personaID: personaID, action: nil)
        }
        return nil
    }

    private func batteryInsight(signal: Signal, recent: [Signal], personaID: String) -> Insight? {
        guard let level = signal.numericValue else { return nil }
        if level < 0.15 && signal.value != "charging" {
            return style(title: "Low battery", body: "Battery is at \(Int(level * 100))%.", severity: .warning, signal: signal, personaID: personaID, action: "Connect to power or enable Low Power Mode.")
        }
        let previous = recent.first { $0.source == .battery && $0.id != signal.id }
        if let prevLevel = previous?.numericValue, prevLevel - level > 0.08 {
            return style(title: "Elevated drain", body: "Battery dropped faster than usual in the recent window.", severity: .notice, signal: signal, personaID: personaID, action: "Review recently used apps or background activity.")
        }
        return nil
    }

    private func storageInsight(signal: Signal, personaID: String) -> Insight? {
        guard let available = signal.numericValue, available < 5.0 else { return nil }
        return style(title: "Storage pressure", body: String(format: "Only %.1f GB free.", available), severity: available < 2.0 ? .warning : .notice, signal: signal, personaID: personaID, action: "Offload unused apps or clear large downloads.")
    }

    private func deviceInsight(signal: Signal, personaID: String) -> Insight? {
        if signal.value.contains("serious") || signal.value.contains("critical") {
            return style(title: "Thermal pressure", body: "Device is under elevated thermal load (\(signal.value)).", severity: .warning, signal: signal, personaID: personaID, action: "Reduce workload or move to a cooler environment.")
        }
        return nil
    }

    private func style(title: String, body: String, severity: DiagnosticEvent.Severity, signal: Signal, personaID: String, action: String?) -> Insight {
        let styledBody: String
        switch personaID {
        case "forge": styledBody = "Technical: \(body)"
        case "eternal": styledBody = "Pattern view: \(body) This may indicate a developing trend."
        default: styledBody = body
        }
        return Insight(title: title, body: styledBody, severity: severity, relatedSignalIDs: [signal.id], personaStyle: personaID, suggestedAction: action)
    }
}
