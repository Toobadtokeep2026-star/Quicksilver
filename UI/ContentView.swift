import SwiftUI

/// Primary Nexus dashboard.
/// Surfaces autonomous persona, live health, system metrics, and recent insights.
struct ContentView: View {
    @EnvironmentObject private var container: DependencyContainer

    private var nexus: NexusCoordinator { container.nexus }
    private var state: NexusState { nexus.state }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    personaCard
                    healthCard
                    metricsGrid
                    insightsSection
                    versionFooter
                }
                .padding()
            }
            .navigationTitle("Quicksilver")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                if !nexus.isActive {
                    nexus.start()
                }
            }
        }
    }

    // MARK: - Persona

    private var personaCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Active Persona", systemImage: "person.crop.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                statusDot(nexus.isActive)
            }

            Text(container.personaManager.activeConfiguration.displayName)
                .font(.title.weight(.semibold))

            Text(container.personaManager.activeConfiguration.shortDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Health

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("System Health", systemImage: "heart.text.square.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text("\(state.overallHealthScore)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(healthColor(state.overallHealthScore))

                VStack(alignment: .leading, spacing: 4) {
                    Text(healthLabel(state.overallHealthScore))
                        .font(.headline)
                    Text("Network \(state.networkHealthScore) · Power \(state.powerHealthScore)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Metrics

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricTile(
                title: "Battery",
                value: state.batteryLevel.map { "\(Int($0 * 100))%" } ?? "—",
                detail: state.batteryState,
                systemImage: "battery.100"
            )
            metricTile(
                title: "Network",
                value: state.networkStatus.capitalized,
                detail: networkDetail,
                systemImage: "wifi"
            )
            metricTile(
                title: "Thermal",
                value: state.thermalState.capitalized,
                detail: state.lowPowerMode ? "Low Power On" : "Normal",
                systemImage: "thermometer.medium"
            )
            metricTile(
                title: "Storage",
                value: state.availableStorageGB.map { String(format: "%.1f GB" , $0) } ?? "—",
                detail: state.totalStorageGB.map { String(format: "of %.0f GB", $0) } ?? "",
                systemImage: "internaldrive"
            )
        }
    }

    private var networkDetail: String {
        var parts: [String] = []
        if state.isNetworkExpensive { parts.append("Expensive") }
        if state.isNetworkConstrained { parts.append("Constrained") }
        return parts.isEmpty ? "OK" : parts.joined(separator: " · ")
    }

    private func metricTile(title: String, value: String, detail: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Insights

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent Insights", systemImage: "lightbulb.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if state.recentInsights.isEmpty {
                Text("No insights yet. Monitoring is active.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(state.recentInsights.prefix(5)) { insight in
                    insightRow(insight)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func insightRow(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                severityBadge(insight.severity)
            }
            Text(insight.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let action = insight.suggestedAction {
                Text(action)
                    .font(.caption2)
                    .foregroundStyle(.tint)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Helpers

    private var versionFooter: some View {
        Text("v\(container.configuration.fullVersionString)")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private func statusDot(_ active: Bool) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(active ? Color.green : Color.secondary)
                .frame(width: 8, height: 8)
            Text(active ? "Live" : "Idle")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func healthColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }

    private func healthLabel(_ score: Int) -> String {
        switch score {
        case 90...: return "Excellent"
        case 75..<90: return "Good"
        case 50..<75: return "Fair"
        default: return "Needs attention"
        }
    }

    private func severityBadge(_ severity: DiagnosticEvent.Severity) -> some View {
        Text(severity.rawValue.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(severityColor(severity).opacity(0.2), in: Capsule())
            .foregroundStyle(severityColor(severity))
    }

    private func severityColor(_ severity: DiagnosticEvent.Severity) -> Color {
        switch severity {
        case .info: return .blue
        case .notice: return .orange
        case .warning: return .orange
        case .critical: return .red
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DependencyContainer())
        .preferredColorScheme(.dark)
}
