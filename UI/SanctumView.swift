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

        ZStack {
            PersonaTheme.cosmicBlack.ignoresSafeArea()
            SanctumAtmosphere(accent: accent)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    sanctumHeader(vm, accent: accent)
                    QuicksilverOrb(status: vm.livingStatus, accent: accent)
                    presenceLine(vm, accent: accent)
                    realmGate(vm, accent: accent)
                    environmentalSigils(vm, accent: accent)
                    if let insight = vm.latestInsight { insightCard(insight, accent: accent) }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }

            VStack { Spacer(); invocationBar(accent: accent) }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAsk) { AskView(container: container) }
        .sheet(isPresented: $showMemory) { MemoryView(container: container) }
        .sheet(isPresented: $showCodex) { CodexView(container: container) }
        .sheet(item: $activeRealm) { realm in
            switch realm {
            case .forge: ForgeView().environment(container)
            case .observatory: EternalObservatoryView().environment(container)
            }
        }
        .onAppear { viewModel.startLiveRefresh() }
        .onDisappear { viewModel.stopLiveRefresh() }
    }

    private func sanctumHeader(_ vm: SanctumViewModel, accent: Color) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SANCTUM").font(.caption.weight(.bold)).tracking(3).foregroundStyle(accent)
                Text("The chamber remembers.").font(.system(size: 27, weight: .semibold, design: .serif)).foregroundStyle(PersonaTheme.mercurySilver)
            }
            Spacer()
            Menu {
                Button("Enter Forge") { activeRealm = .forge }
                Button("Enter Eternal Observatory") { activeRealm = .observatory }
                Divider()
                Button("Memory") { showMemory = true }
                Button("Codex") { showCodex = true }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundStyle(PersonaTheme.mercurySilver)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }

    private func presenceLine(_ vm: SanctumViewModel, accent: Color) -> some View {
        HStack(spacing: 10) {
            Circle().fill(accent).frame(width: 7, height: 7).shadow(color: accent, radius: 6)
            Text(vm.livingStatus).font(.subheadline).foregroundStyle(PersonaTheme.mercurySilver)
            Spacer()
            Text(vm.activeChamber.displayName.uppercased()).font(.caption2.weight(.bold)).tracking(1.4).foregroundStyle(.secondary)
        }
    }

    private func realmGate(_ vm: SanctumViewModel, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REALMS").font(.caption2.weight(.bold)).tracking(2).foregroundStyle(.secondary)
            HStack(spacing: 10) {
                RealmCard(title: "Forge", subtitle: "Create", symbol: "flame", accent: PersonaTheme.forgeEmber) { activeRealm = .forge }
                RealmCard(title: "Eternal", subtitle: "Observe", symbol: "eye", accent: PersonaTheme.eternalViolet) { activeRealm = .observatory }
            }
        }
    }

    private func environmentalSigils(_ vm: SanctumViewModel, accent: Color) -> some View {
        HStack(spacing: 8) {
            Sigil(title: "POWER", value: vm.batteryLevelText, accent: accent)
            Sigil(title: "NETWORK", value: vm.networkStatus, accent: accent)
            Sigil(title: "THERMAL", value: vm.thermalState, accent: accent)
            Sigil(title: "HEALTH", value: "\(vm.overallHealthScore)", accent: PersonaTheme.healthColor(vm.overallHealthScore))
        }
    }

    private func insightCard(_ insight: Insight, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NEXUS WHISPER").font(.caption2.weight(.bold)).tracking(1.6).foregroundStyle(accent)
            Text(insight.body).font(.subheadline).foregroundStyle(PersonaTheme.mercurySilver).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.48), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(accent.opacity(0.22)))
    }

    private func invocationBar(accent: Color) -> some View {
        HStack(spacing: 0) {
            RitualButton(symbol: "bubble.left.and.bubble.right", label: "Invoke") { showAsk = true }
            RitualButton(symbol: "brain.head.profile", label: "Memory") { showMemory = true }
            RitualButton(symbol: "book.closed", label: "Codex") { showCodex = true }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.72))
        .overlay(alignment: .top) { Rectangle().fill(accent.opacity(0.25)).frame(height: 1) }
    }
}

private enum Realm: String, Identifiable { case forge, observatory; var id: String { rawValue } }

private struct SanctumAtmosphere: View {
    let accent: Color
    var body: some View {
        TimelineView(.animation) { context in
            let pulse = 0.5 + 0.5 * sin(context.date.timeIntervalSinceReferenceDate * 0.55)
            ZStack {
                RadialGradient(colors: [accent.opacity(0.18 + pulse * 0.06), .clear], center: .center, startRadius: 20, endRadius: 390)
                Circle().stroke(accent.opacity(0.07 + pulse * 0.03), lineWidth: 1).frame(width: 330 + pulse * 20)
                Circle().stroke(PersonaTheme.deepViolet.opacity(0.12), lineWidth: 1).frame(width: 500)
            }
            .blur(radius: 1)
            .ignoresSafeArea()
        }
    }
}

private struct QuicksilverOrb: View {
    let status: String
    let accent: Color
    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let pulse = 0.96 + 0.04 * sin(t * 1.7)
            ZStack {
                Circle().fill(accent.opacity(0.08)).frame(width: 245).blur(radius: 22)
                Circle().stroke(accent.opacity(0.20), lineWidth: 1).frame(width: 198)
                Circle().fill(AngularGradient(colors: [accent, PersonaTheme.runicViolet, PersonaTheme.mercurySilver, accent], center: .center)).frame(width: 142 * pulse).shadow(color: accent.opacity(0.75), radius: 28)
                Circle().fill(.black.opacity(0.35)).frame(width: 116 * pulse)
                Image(systemName: "bolt.horizontal.fill").font(.system(size: 31, weight: .light)).foregroundStyle(PersonaTheme.mercurySilver).rotationEffect(.degrees(sin(t * 0.5) * 8))
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 260)
        .accessibilityLabel("Quicksilver presence")
        .accessibilityValue(status)
    }
}

private struct RealmCard: View {
    let title: String; let subtitle: String; let symbol: String; let accent: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol).font(.title2).foregroundStyle(accent)
                Spacer()
                Text(title).font(.headline).foregroundStyle(PersonaTheme.mercurySilver)
                Text(subtitle.uppercased()).font(.caption2.weight(.bold)).tracking(1.2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.52), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(accent.opacity(0.24)))
        }
        .buttonStyle(.plain)
    }
}

private struct Sigil: View {
    let title: String; let value: String; let accent: Color
    var body: some View {
        VStack(spacing: 4) { Text(title).font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(.secondary); Text(value).font(.caption.weight(.semibold)).foregroundStyle(PersonaTheme.mercurySilver).lineLimit(1) }
            .frame(maxWidth: .infinity).padding(.vertical, 9).background(.ultraThinMaterial.opacity(0.3), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct RitualButton: View {
    let symbol: String; let label: String; let action: () -> Void
    var body: some View { Button(action: action) { VStack(spacing: 4) { Image(systemName: symbol).font(.callout); Text(label).font(.caption2) }.foregroundStyle(PersonaTheme.mercurySilver).frame(maxWidth: .infinity) }.buttonStyle(.plain) }
}
