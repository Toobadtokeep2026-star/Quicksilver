import SwiftUI

/// Root content view.
/// Surfaces the active persona, live Nexus health signals, and the most recent insight.
/// Follows HIG: clear hierarchy, readable typography, sufficient contrast, no decorative noise.
struct ContentView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    personaHeader
                    nexusStatusCard
                    metricsRow
                    if let insight = container.nexus.state.recentInsights.first {
                        insightCard(insight)
                    }
                }
                .padding()
            }
            .navigationTitle("Quicksilver")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                container.nexus.start()
            }
        }
    }

    // MARK: - Persona

    private var personaHeader: some View {
        let config = container.activeConfiguration
        return VStack(alignment: .leading, spacing: 8) {
            Text(config.displayName)
                .font(.largeTitle.weight(.semibold))
            Text(config.shortDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Nexus status

    private var nexusStatusCard: some View {
        let state = container.nexus.state
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Nexus", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(state.isActive ? .green : .secondary)
                        .frame(width: 8, height: 8)
                    Text(state.isActive ? "Active" : "Inactive")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Overall health
            HStack {
                Text("Overall health")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(state.overallHealthScore)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(healthColor(state.overallHealthScore))
            }

            if state.lowPowerMode {
                Label("Low Power Mode", systemImage: "battery.25")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Metrics

    private var metricsRow: some View {
        let state = container.nexus.state
        return HStack(spacing: 12) {
            metricTile(
                title: "Battery",
                value: state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "—",
                subtitle: state.batteryState,
                systemImage: "battery.100"
            )
            metricTile(
                title: "Network",
                value: state.networkStatus.capitalized,
                subtitle: state.isNetworkExpensive ? "Expensive" : (state.isNetworkConstrained ? "Constrained" : "OK"),
                systemImage: "wifi"
            )
            metricTile(
                title: "Thermal",
                value: state.thermalState.capitalized,
                subtitle: nil,
                systemImage: "thermometer.medium"
            )
        }
    }

    private func metricTile(title: String, value: String, subtitle: String?, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Insight

    private func insightCard(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Latest Insight", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                Text(insight.personaStyle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(insight.title)
                .font(.subheadline.weight(.medium))
            Text(insight.body)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let action = insight.suggestedAction {
                Text(action)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Helpers

    private func healthColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
}

#Preview {
    ContentView()
        .environment(DependencyContainer())
}
