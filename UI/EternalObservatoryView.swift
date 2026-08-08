import SwiftUI

/// The Eternal Observatory: observation rendered as a living constellation.
struct EternalObservatoryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PersonaTheme.cosmicBlack.ignoresSafeArea()
            Circle()
                .fill(PersonaTheme.eternalViolet.opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(y: -120)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ETERNAL OBSERVATORY")
                            .font(.caption.weight(.bold))
                            .tracking(2.6)
                            .foregroundStyle(PersonaTheme.eternalViolet)
                        Text("Nothing escapes observation.")
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(PersonaTheme.mercurySilver)
                        Text("NEXUS · MEMORY · VESSEL · TIME")
                            .font(.caption2.weight(.bold))
                            .tracking(1.4)
                            .foregroundStyle(.secondary)
                    }

                    constellation
                    observatoryCard("Nexus", "Live signals and emerging insight", "point.3.connected.trianglepath.dotted", PersonaTheme.eternalViolet)
                    observatoryCard("Memory", "The record of what the chamber remembers", "brain.head.profile", PersonaTheme.eternalViolet)
                    observatoryCard("Vessel", "Device and environmental state", "iphone.gen3", PersonaTheme.eternalViolet)
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

    private var constellation: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.35))
                .frame(height: 210)
            ForEach(0..<7, id: \.self) { index in
                Circle()
                    .fill(PersonaTheme.eternalViolet.opacity(index == 0 ? 0.95 : 0.45))
                    .frame(width: index == 0 ? 14 : 8, height: index == 0 ? 14 : 8)
                    .offset(
                        x: CGFloat((index * 43) % 170) - 85,
                        y: CGFloat((index * 67) % 120) - 60
                    )
            }
            Text("NEXUS CONSTELLATION")
                .font(.caption2.weight(.bold))
                .tracking(1.8)
                .foregroundStyle(PersonaTheme.eternalViolet)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 18)
        }
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(PersonaTheme.eternalViolet.opacity(0.18)))
        .accessibilityLabel("Nexus constellation visualization")
    }

    private func observatoryCard(_ title: String, _ subtitle: String, _ symbol: String, _ accent: Color) -> some View {
        HStack(spacing: 15) {
            Image(systemName: symbol)
                .foregroundStyle(accent)
                .frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(PersonaTheme.mercurySilver)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.45), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(accent.opacity(0.16)))
        .accessibilityElement(children: .combine)
    }
}
