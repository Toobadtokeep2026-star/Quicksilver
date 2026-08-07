import SwiftUI
import Core

/// Subtle living environment of the Sanctum.
/// Particles, mercury flow, slow celestial motion.
/// Intensity and palette respond to the active chamber.
struct AmbientLayer: View {
    let personaID: String
    let chamber: SanctumChamber

    var body: some View {
        let accent = PersonaTheme.accent(for: personaID)
        let intensity = chamber.ambientIntensity
        let particleCount = Int(12 + intensity * 22)

        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                // Chamber-reactive drifting particles
                for i in 0..<particleCount {
                    let seed = Double(i) * 1.37
                    let speed = 0.05 + intensity * 0.06
                    let x = (sin(t * speed + seed) * 0.42 + 0.5) * size.width
                    let y = (cos(t * (speed * 0.75) + seed * 1.3) * 0.42 + 0.5) * size.height
                    let baseOpacity = 0.05 + 0.10 * intensity
                    let opacity = baseOpacity + 0.05 * sin(t * 0.35 + seed)
                    let radius = 1.6 + intensity * 1.8

                    let rect = CGRect(x: x, y: y, width: radius, height: radius)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(accent.opacity(opacity))
                    )
                }

                // Mercury sheen lines — denser and brighter in Forge
                let lineCount = chamber == .forge ? 6 : 4
                let lineOpacity = 0.025 + intensity * 0.04
                for i in 0..<lineCount {
                    let y = size.height * (0.15 + Double(i) * (0.7 / Double(lineCount)))
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y + sin(t * 0.4 + Double(i)) * 8 * intensity))
                    path.addLine(to: CGPoint(x: size.width, y: y + cos(t * 0.35 + Double(i)) * 8 * intensity))
                    context.stroke(
                        path,
                        with: .color(PersonaTheme.mercurySilver.opacity(lineOpacity)),
                        lineWidth: chamber == .forge ? 1.2 : 1.0
                    )
                }

                // Soft central glow when a chamber is fully awake
                if chamber != .sanctum {
                    let glowRadius = min(size.width, size.height) * (0.22 + intensity * 0.12)
                    let glowRect = CGRect(
                        x: size.width * 0.5 - glowRadius,
                        y: size.height * 0.38 - glowRadius * 0.6,
                        width: glowRadius * 2,
                        height: glowRadius * 1.4
                    )
                    context.fill(
                        Path(ellipseIn: glowRect),
                        with: .radialGradient(
                            Gradient(colors: [
                                accent.opacity(0.07 * intensity),
                                accent.opacity(0)
                            ]),
                            center: CGPoint(x: size.width * 0.5, y: size.height * 0.38),
                            startRadius: 0,
                            endRadius: glowRadius
                        )
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.9), value: chamber)
    }
}
