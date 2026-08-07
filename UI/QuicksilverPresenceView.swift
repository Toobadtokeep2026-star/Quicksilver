import SwiftUI
import Core

/// Quicksilver is not summoned. He is already here.
/// A permanent ambient presence in the Sanctum.
struct QuicksilverPresenceView: View {
    let personaID: String
    let chamber: SanctumChamber
    let livingStatus: String

    @State private var pulse = false
    @State private var glyphRotation: Double = 0

    var body: some View {
        let accent = PersonaTheme.accent(for: personaID)
        let radius = PersonaTheme.cardCornerRadius(for: personaID)

        VStack(spacing: 16) {
            ZStack {
                // Outer reflective aura
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                accent.opacity(0.25),
                                accent.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(pulse ? 1.08 : 1.0)

                // Liquid chrome core
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                PersonaTheme.mercurySilver.opacity(0.9),
                                accent.opacity(0.7),
                                PersonaTheme.liquidMetal.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .strokeBorder(PersonaTheme.mercurySilver.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: accent.opacity(0.5), radius: 16)

                // Rotating glyph ring (subtle)
                Circle()
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [4, 8])
                    )
                    .foregroundStyle(accent.opacity(0.35))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(glyphRotation))
            }
            .onAppear {
                withAnimation(PersonaTheme.thinkingPulse) {
                    pulse = true
                }
                withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                    glyphRotation = 360
                }
            }

            VStack(spacing: 6) {
                Text(presenceTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(PersonaTheme.mercurySilver)

                Text(livingStatus)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: radius + 4, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius + 4, style: .continuous)
                .strokeBorder(accent.opacity(0.2), lineWidth: 1)
        )
    }

    private var presenceTitle: String {
        switch chamber {
        case .forge:
            return "Forge is awake"
        case .eternal:
            return "Eternal observes"
        case .sanctum:
            return "Quicksilver"
        }
    }
}
