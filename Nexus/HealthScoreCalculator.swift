import Foundation

/// Pure, testable health scoring.
struct HealthScoreCalculator: Sendable {
    struct Input: Sendable {
        var isNetworkConnected: Bool = false
        var isNetworkExpensive: Bool = false
        var isNetworkConstrained: Bool = false
        var batteryLevel: Double? = nil
        var isLowPowerMode: Bool = false
        var availableStorageGB: Double? = nil
        var totalStorageGB: Double? = nil
        var thermalState: String = "unknown"
    }

    struct Result: Sendable {
        var network: Int
        var power: Int
        var storage: Int
        var device: Int
        var overall: Int
    }

    func calculate(_ input: Input) -> Result {
        let network = networkScore(input)
        let power = powerScore(input)
        let storage = storageScore(input)
        let device = deviceScore(input)

        let overall = Int(
            Double(network) * 0.35 +
            Double(power) * 0.35 +
            Double(storage) * 0.15 +
            Double(device) * 0.15
        )

        return Result(
            network: network,
            power: power,
            storage: storage,
            device: device,
            overall: min(max(overall, 0), 100)
        )
    }

    private func networkScore(_ input: Input) -> Int {
        guard input.isNetworkConnected else { return 15 }
        if input.isNetworkConstrained { return 55 }
        if input.isNetworkExpensive { return 70 }
        return 95
    }

    private func powerScore(_ input: Input) -> Int {
        guard let level = input.batteryLevel, level >= 0 else { return 50 }
        var score = Int(level * 100)
        if input.isLowPowerMode { score = max(score - 10, 0) }
        return min(max(score, 0), 100)
    }

    private func storageScore(_ input: Input) -> Int {
        guard let available = input.availableStorageGB,
              let total = input.totalStorageGB,
              total > 0 else { return 70 }
        let freeRatio = available / total
        if freeRatio < 0.05 { return 20 }
        if freeRatio < 0.10 { return 40 }
        if freeRatio < 0.20 { return 65 }
        return 90
    }

    private func deviceScore(_ input: Input) -> Int {
        switch input.thermalState {
        case "nominal": return 95
        case "fair": return 75
        case "serious": return 40
        case "critical": return 15
        default: return 60
        }
    }
}
