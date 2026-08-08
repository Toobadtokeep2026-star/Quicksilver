import SwiftUI
import Core
import Personas
import Nexus

struct SanctumView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: SanctumViewModel
    @State private var activeRealm: Realm?
    @State private var showAsk = false
    @State private var showMemory = false
    @State private var showCodex = false

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: SanctumViewModel(container: container))
    }

    var body: some View {
        let vm = viewModel
        let accent = PersonaTheme.accent(for: vm.activePersonaID)
        let secondary = PersonaTheme.secondaryAccent(for: vm.activePersonaID)

        ZStack(alignment: .bottom) {
            PersonaTheme.cosmicBlack.ignoresSafeArea()
            SanctumAtmosphere(accent: accent, secondary: secondary)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header(vm, accent: accent)
                    QuicksilverPresence(status: vm.livingStatus, accent: accent, secondary: secondary)
                    presence(vm, accent: accent)
                    realms(accent: accent)
                    environment(vm, accent: accent)

                    if let insight = vm.latestInsight {
                        insightCard(insight, accent: accent)
                    } else {
                        emptyWhisper(accent: accent)
                    }

                    Spacer(minLength: 116)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .scrollBounceBehavior(.basedOnSize)

            invocationBar(accent: accent)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAsk) { AskView(container: container) }
        .sheet(isPresented: $showMemory) { MemoryView(container: container) }
        .sheet(isPresented: $showCodex) { CodexView().environment(container) }
        .sheet(item: $activeRealm) { realm in
            switch realm {
            case .forge:
                ForgeView().environment(container)
            case .observatory:
                EternalObservatoryView().environment(container)
            }
        }
        .task {
            viewModel.startLiveRefresh()
        }
        .onDisappear {
            viewModel.stopLiveRefresh()
        }
    }

    private func header(_ vm: SanctumViewModel, accent: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("SANCTUM")
                    .font(.caption.weight(.bold))
                    .tracking(3)
                    .foregroundStyle(accent)
                Text("The chamber remembers.")
                    .font(.system(size: 27, weight: .semibold, design: .serif))
                    .foregroundStyle(PersonaTheme.mercurySilver)
                    .minimumScaleFactor(0.85)
                Text(vm.activeChamber.displayName.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            Menu {
                Button("Enter Forge") { activeRealm = .forge }
                Button("Enter Eternal Observatory") { activeRealm = .observatory }
                Divider()
                Button("Memory") { showMemory = true }
                Button("Codex") { showCodex = true }
            } label: {
                Image(systemName: "circle.grid.2x2")
                    .font(.headline)
                    .foregroundStyle(PersonaTheme.mercurySilver)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().strokeBorder(accent.opacity(0.22)))
            }
            .accessibilityLabel("Open Sanctum realms and tools")
        }
    }

    private func presence(_ vm: SanctumViewModel, accent: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(accent)
                .frame(width: 7, height: 7)
                .shadow(color: accent, radius: 6)
            Text(vm.livingStatus)
                .font(.subheadline)
                .foregroundStyle(PersonaTheme.mercurySilver)
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(vm.activePersonaID.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(accent)
        }
        .accessibilityElement(children: .combine)
    }

    private func realms(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("REALMS", accent: accent)
            HStack(spacing: 10) {
                SanctumRealmCard(
                    title: "Forge",
                    subtitle: "Create",
                    symbol: "flame",
                    accent: PersonaTheme.forgeEmber
                ) {
                    activeRealm = .forge
                }
                SanctumRealmCard(
                    title: "Eternal",
                    subtitle: "Observe",
                    symbol: "eye",
                    accent: PersonaTheme.eternalViolet
                ) {
                    activeRealm = .observatory
                }
            }
        }
    }

    private func environment(_ vm: SanctumViewModel, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("ENVIRONMENT", accent: accent)
            HStack(spacing: 8) {
                SanctumSigil(title: "POWER", value: vm.batteryLevelText, accent: accent)
                SanctumSigil(title: "NETWORK", value: vm.networkStatus, accent: accent)
                SanctumSigil(title: "THERMAL", value: vm.thermalState, accent: accent)
                SanctumSigil(
                    title: "HEALTH",
                    value: "\(vm.overallHealthScore)",
                    accent: PersonaTheme.healthColor(vm.overallHealthScore)
                )
            }
        }
    }

    private func insightCard(_ insight: Insight, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("NEXUS WHISPER")
                    .font(.caption2.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(accent)
                Spacer()
                Image(systemName: "waveform.path.ecg")
                    .font(.caption)
                    .foregroundStyle(accent.opacity(0.75))
            }
            Text(insight.body)
                .font(.subheadline)
                .foregroundStyle(PersonaTheme.mercurySilver)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.48), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(accent.opacity(0.22))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nexus whisper")
    }

    private func emptyWhisper(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("NEXUS IS LISTENING")
                .font(.caption2.weight(.bold))
                .tracking(1.6)
                .foregroundStyle(accent)
            Text("No new signal has crossed the chamber.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.34), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func sectionLabel(_ title: String, accent: Color) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(accent.opacity(0.45))
                .frame(width: 18, height: 1)
            Text(title)
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)
        }
    }

    private func invocationBar(accent: Color) -> some View {
        HStack(spacing: 0) {
            SanctumRitualButton(symbol: "bubble.left.and.bubble.right", label: "Invoke") {
                showAsk = true
            }
            SanctumRitualButton(symbol: "brain.head.profile", label: "Memory") {
                showMemory = true
            }
            SanctumRitualButton(symbol: "book.closed", label: "Codex") {
                showCodex = true
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.78))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(accent.opacity(0.25))
                .frame(height: 1)
        }
    }
}

private enum Realm: String, Identifiable {
    case forge
    case observatory

    var id: String { rawValue }
}
