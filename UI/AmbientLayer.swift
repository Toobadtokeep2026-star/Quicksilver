import SwiftUI

/// Subtle living environment of the Sanctum.
/// Particles, mercury flow hints, slow celestial motion.
/// Every animation communicates life.
struct AmbientLayer: View {
    let personaID: String
    let chamber: SanctumChamber

    @State private var phase: CGFloat = 0

    var body: some View {
        let accent = PersonaTheme.accent(for: personaID)

        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                // Slow drifting particles
                for i in 0..<18 {
                    let seed = Double(i) * 1.37
                    let x = (sin(t * 0.07 + seed) * 0.4 + 0.5) * size.width
                    let y = (cos(t * 0.05 + seed * 1.3) * 0.4 + 0.5) * size.height
                    let opacity = 0.08 + 0.06 * sin(t * 0.3 + seed)

                    let rect = CGRect(x: x, y: y, width: 2.5, height: 2.5)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(accent.opacity(opacity))
                    )
                }

                // Faint mercury sheen lines
                for i in 0..<4 {
                    let y = size.height * (0.2 + Double(i) * 0.2)
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y + sin(t * 0.4 + Double(i)) * 6))
                    path.addLine(to: CGPoint(x: size.width, y: y + cos(t * 0.35 + Double(i)) * 6))
                    context.stroke(
                        path,
                        with: .color(PersonaTheme.mercurySilver.opacity(0.03)),
                        lineWidth: 1
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .opacity(chamber == .forge ? 0.9 : 0.7)
    }
}
