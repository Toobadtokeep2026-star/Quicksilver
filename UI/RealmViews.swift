import SwiftUI
import Core

struct ForgeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showDiagnostics = false
    @State private var showAsk = false

    var body: some View {
        RealmSurface(title: "Forge", subtitle: "Where ideas become instruments.", accent: PersonaTheme.forgeEmber) {
            VStack(spacing: 14) {
                InstrumentCard(symbol: "flame", title: "Alchemy", detail: "Shape prompts, automations, and experiments.", accent: PersonaTheme.forgeEmber) {
                    showAsk = true
                }
                InstrumentCard(symbol: "waveform.path.ecg", title: "Diagnostics", detail: "Read the machine as an instrument, not a status page.", accent: PersonaTheme.forgeEmber) {
                    showDiagnostics = true
                }
                InstrumentCard(symbol: "bolt.fill", title: "Automations", detail: "Actions waiting to be forged into rituals.", accent: PersonaTheme.forgeGold) { }
            }
        }
        .sheet(isPresented: $showAsk) { AskView(container: container) }
        .sheet(isPresented: $showDiagnostics) { DiagnosticsView(container: container) }
    }
}

struct EternalObservatoryView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        RealmSurface(title: "Eternal Observatory", subtitle: "Nothing is hidden from the stars.", accent: PersonaTheme.eternalViolet) {
            VStack(spacing: 14) {
                ObservatoryConstellation()
                InstrumentCard(symbol: "brain.head.profile", title: "Memory", detail: "The long view of what Mercury knows.", accent: PersonaTheme.eternalViolet) { }
                InstrumentCard(symbol: "network", title: "Nexus", detail: "Signals from the living system.", accent: PersonaTheme.eternalViolet) { }
                InstrumentCard(symbol: "iphone.gen3", title: "Device", detail: "Health, battery, thermal and network state.", accent: PersonaTheme.eternalViolet) { }
            }
        }
    }
}

private struct RealmSurface<Content: View>: View {
    let title: String
    let subtitle: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            PersonaTheme.cosmicBlack.ignoresSafeArea()
            RadialGradient(colors: [accent.opacity(0.16), .clear], center: .top, startRadius: 20, endRadius: 500).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("MERCURY")
                        .font(.caption.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(accent)
                    Text(title)
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundStyle(PersonaTheme.mercurySilver)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    content
                }
                .padding(22)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct InstrumentCard: View {
    let symbol: String
    let title: String
    let detail: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: symbol)
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(accent.opacity(0.12), in: Circle())
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(PersonaTheme.mercurySilver)
                    Text(detail).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.55), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(accent.opacity(0.22)))
        }
        .buttonStyle(.plain)
    }
}

private struct ObservatoryConstellation: View {
    var body: some View {
        ZStack {
            Circle().stroke(PersonaTheme.eternalViolet.opacity(0.18), lineWidth: 1).frame(height: 220)
            Circle().stroke(PersonaTheme.eternalViolet.opacity(0.10), lineWidth: 1).frame(height: 150)
            ForEach(0..<7, id: \.self) { i in
                Circle().fill(PersonaTheme.eternalViolet.opacity(0.8)).frame(width: i == 3 ? 12 : 5, height: i == 3 ? 12 : 5)
                    .offset(x: CGFloat(cos(Double(i) * 0.9)) * 90, y: CGFloat(sin(Double(i) * 1.7)) * 80)
            }
            Image(systemName: "eye.fill").font(.title).foregroundStyle(PersonaTheme.eternalViolet).shadow(color: PersonaTheme.eternalViolet.opacity(0.8), radius: 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(.ultraThinMaterial.opacity(0.35), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
