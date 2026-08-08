import SwiftUI

/// The Forge: Mercury's workshop. Diagnostics and creation are presented as instruments.
struct ForgeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PersonaTheme.cosmicBlack.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    realmHeader
                    instrument(title: "Diagnostics", subtitle: "Inspect the vessel", symbol: "stethoscope", accent: PersonaTheme.forgeEmber)
                    instrument(title: "Experiments", subtitle: "Forge a new operation", symbol: "flame", accent: PersonaTheme.forgeEmber)
                    instrument(title: "Nexus Tools", subtitle: "Shape what Mercury observes", symbol: "waveform.path.ecg", accent: PersonaTheme.forgeEmber)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Seal") { dismiss() }
            }
        }
    }

    private var realmHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FORGE")
                .font(.caption.weight(.bold))
                .tracking(3)
                .foregroundStyle(PersonaTheme.forgeEmber)
            Text("The workshop never sleeps.")
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(PersonaTheme.mercurySilver)
            Text("INSTRUMENTS · EXPERIMENTS · CREATION")
                .font(.caption2.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(.secondary)
        }
    }

    private func instrument(title: String, subtitle: String, symbol: String, accent: Color) -> some View {
        Button { } label: {
            HStack(spacing: 16) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(accent)
                    .frame(width: 46, height: 46)
                    .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(PersonaTheme.mercurySilver)
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.55), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(accent.opacity(0.18)))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}
