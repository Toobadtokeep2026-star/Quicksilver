import SwiftUI

/// Root content view driven by HomeViewModel.
struct ContentView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: HomeViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    dashboard(vm)
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel = HomeViewModel(container: container)
                        }
                }
            }
            .navigationTitle("Quicksilver")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MemoryView()
                    } label: {
                        Label("Memory", systemImage: "brain.head.profile")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "memory" {
                    MemoryView()
                }
            }
        }
    }

    @ViewBuilder
    private func dashboard(_ vm: HomeViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                personaHeader(vm)
                personaSwitcher(vm)
                nexusStatusCard(vm)
                metricsRow(vm)
                if let insight = vm.latestInsight {
                    insightCard(insight)
                }
            }
            .padding()
        }
        .onAppear { vm.refresh() }
    }

    // MARK: - Persona

    private func personaHeader(_ vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.personaDisplayName)
                .font(.largeTitle.weight(.semibold))
            Text(vm.personaDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func personaSwitcher(_ vm: HomeViewModel) -> some View {
        Picker("Persona", selection: Binding(
            get: { vm.activePersonaID },
            set: { vm.switchPersona(to: $0) }
        )) {
            ForEach(vm.availablePersonas, id: \.id) { config in
                Text(config.displayName).tag(config.id)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Nexus status

    private func nexusStatusCard(_ vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Nexus", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(vm.isNexusActive ? .green : .secondary)
                        .frame(width: 8, height: 8)
                    Text(vm.isNexusActive ? "Active" : "Inactive")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("Overall health")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(vm.overallHealthScore)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(healthColor(vm.overallHealthScore))
            }

            if vm.lowPowerMode {
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

    private func metricsRow(_ vm: HomeViewModel) -> some View {
        HStack(spacing: 12) {
            metricTile(title: "Battery", value: vm.batteryLevelText, subtitle: vm.batteryState, systemImage: "battery.100")
            metricTile(title: "Network", value: vm.networkStatus, subtitle: vm.networkSubtitle, systemImage: "wifi")
            metricTile(title: "Thermal", value: vm.thermalState, subtitle: nil, systemImage: "thermometer.medium")
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
