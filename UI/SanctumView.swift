import SwiftUI
import Core
import Personas
import Nexus

/// The Sanctum — primary experiential surface of Mercury.
/// Not a dashboard. A place.
/// Quicksilver is already here. The Forge and Eternal awaken as needed.
struct SanctumView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: SanctumViewModel?
    @State private var showCodex = false
    @State private var showAsk = false
    @State private var showMemory = false
    @State private var showDiagnostics = false

    var body: some View {
        Group {
            if let vm = viewModel {
                sanctumContent(vm)
            } else {
                ZStack {
                    PersonaTheme.cosmicBlack.ignoresSafeArea()
                    ProgressView()
                        .tint(PersonaTheme.mercurySilver)
                }
                .onAppear { viewModel = SanctumViewModel(container: container) }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func sanctumContent(_ vm: SanctumViewModel) -> some View {
        let personaID = vm.activePersonaID
        let accent = PersonaTheme.accent(for: personaID)
        let radius = PersonaTheme.cardCornerRadius(for: personaID)

        ZStack {
            // Deep cosmic void
            PersonaTheme.cosmicBlack.ignoresSafeArea()

            // Ambient living layer
            AmbientLayer(personaID: personaID, chamber: vm.activeChamber)

            // Main Sanctum content
            VStack(spacing: 0) {
                // Living status / presence bar
                presenceBar(vm, accent: accent, radius: radius)

                ScrollView {
                    VStack(spacing: 20 * PersonaTheme.density(for: personaID)) {
                        // Quicksilver Presence
                        QuicksilverPresenceView(
                            personaID: personaID,
                            chamber: vm.activeChamber,
                            livingStatus: vm.livingStatus
                        )

                        // Chamber indicators (awakened state)
                        chamberIndicators(vm, accent: accent, radius: radius)

                        // Latest insight (environmental storytelling)
                        if let insight = vm.latestInsight {
                            insightFragment(insight, personaID: personaID, accent: accent, radius: radius)
                        }

                        // Subtle metrics as environmental signals, not dashboard tiles
                        environmentalSignals(vm, radius: radius)
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }

            // Bottom ritual bar (not a tab bar)
            VStack {
                Spacer()
                ritualBar(accent: accent)
            }
        }
        .sheet(isPresented: $showCodex) {
            NavigationStack {
                CodexView()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showAsk) {
            NavigationStack {
                AskView()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showMemory) {
            NavigationStack {
                MemoryView()
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showDiagnostics) {
            NavigationStack {
                DiagnosticsView()
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            vm.refresh()
            vm.startLiveRefresh()
        }
        .onDisappear {
            vm.stopLiveRefresh()
        }
        .animation(PersonaTheme.spring(for: personaID), value: vm.activeChamber)
        .animation(PersonaTheme.spring(for: personaID), value: personaID)
    }

    // MARK: - Presence Bar

    private func presenceBar(_ vm: SanctumViewModel, accent: Color, radius: CGFloat) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accent)
                .frame(width: 8, height: 8)
                .shadow(color: accent.opacity(0.7), radius: 4)

            Text(vm.livingStatus)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PersonaTheme.mercurySilver)
                .lineLimit(2)

            Spacer()

            Text(vm.activeChamber.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(accent.opacity(0.15), in: Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial.opacity(0.85))
    }

    // MARK: - Chamber Indicators

    private func chamberIndicators(_ vm: SanctumViewModel, accent: Color, radius: CGFloat) -> some View {
        HStack(spacing: 12) {
            chamberPill(
                title: "Forge",
                subtitle: "Creation",
                isAwake: vm.activeChamber == .forge || vm.activeChamber == .sanctum,
                accent: PersonaTheme.accent(for: "forge"),
                radius: radius
            )
            chamberPill(
                title: "Eternal",
                subtitle: "Observation",
                isAwake: vm.activeChamber == .eternal || vm.activeChamber == .sanctum,
                accent: PersonaTheme.accent(for: "eternal"),
                radius: radius
            )
        }
    }

    private func chamberPill(title: String, subtitle: String, isAwake: Bool, accent: Color, radius: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isAwake ? accent : .secondary)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(isAwake ? accent.opacity(0.45) : Color.clear, lineWidth: 1)
        )
        .opacity(isAwake ? 1.0 : 0.55)
    }

    // MARK: - Insight Fragment

    private func insightFragment(_ insight: Insight, personaID: String, accent: Color, radius: CGFloat) -> some View {
        let display = InsightPresenter.present(insight, personaID: personaID)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(accent)
                Text("Fragment")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(accent)
                Spacer()
            }
            Text(display.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PersonaTheme.mercurySilver)
            Text(display.body)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(accent.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Environmental Signals

    private func environmentalSignals(_ vm: SanctumViewModel, radius: CGFloat) -> some View {
        HStack(spacing: 10) {
            signalChip(title: "Power", value: vm.batteryLevelText)
            signalChip(title: "Network", value: vm.networkStatus)
            signalChip(title: "Thermal", value: vm.thermalState)
        }
    }

    private func signalChip(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.caption.weight(.medium))
                .foregroundStyle(PersonaTheme.mercurySilver.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.6), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Ritual Bar

    private func ritualBar(accent: Color) -> some View {
        HStack(spacing: 28) {
            ritualButton(systemImage: "text.bubble", label: "Speak") { showAsk = true }
            ritualButton(systemImage: "brain.head.profile", label: "Archive") { showMemory = true }
            ritualButton(systemImage: "waveform.path.ecg", label: "Signals") { showDiagnostics = true }
            ritualButton(systemImage: "scroll", label: "Codex") { showCodex = true }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(accent.opacity(0.2))
                .frame(height: 1)
        }
    }

    private func ritualButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(PersonaTheme.mercurySilver.opacity(0.9))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chamber

enum SanctumChamber: String, Equatable {
    case sanctum
    case forge
    case eternal

    var displayName: String {
        switch self {
        case .sanctum: return "Sanctum"
        case .forge: return "The Forge"
        case .eternal: return "The Eternal"
        }
    }
}
