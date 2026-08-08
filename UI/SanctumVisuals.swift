import SwiftUI

struct SanctumAtmosphere: View {
    let accent: Color
    let secondary: Color

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let pulse = 0.5 + 0.5 * sin(time * 0.55)
            ZStack {
                RadialGradient(
                    colors: [accent.opacity(0.18 + pulse * 0.06), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 390
                )
                Circle()
                    .stroke(accent.opacity(0.07 + pulse * 0.03), lineWidth: 1)
                    .frame(width: 330 + pulse * 20)
                Circle()
                    .stroke(secondary.opacity(0.12), lineWidth: 1)
                    .frame(width: 500)
                    .rotationEffect(.degrees(time.truncatingRemainder(dividingBy: 360)))
            }
            .blur(radius: 1)
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct QuicksilverPresence: View {
    let status: String
    let accent: Color
    let secondary: Color

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let pulse = 0.96 + 0.04 * sin(time * 1.7)
            ZStack {
                Circle()
                    .fill(accent.opacity(0.08))
                    .frame(width: 245)
                    .blur(radius: 22)
                Circle()
                    .stroke(accent.opacity(0.20), lineWidth: 1)
                    .frame(width: 198)
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [accent, secondary, PersonaTheme.mercurySilver, accent],
                            center: .center
                        )
                    )
                    .frame(width: 142 * pulse)
                    .shadow(color: accent.opacity(0.72), radius: 28)
                Circle()
                    .fill(.black.opacity(0.34))
                    .frame(width: 116 * pulse)
                Image(systemName: "bolt.horizontal.fill")
                    .font(.system(size: 31, weight: .light))
                    .foregroundStyle(PersonaTheme.mercurySilver)
                    .rotationEffect(.degrees(sin(time * 0.5) * 8))
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 250)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quicksilver presence")
        .accessibilityValue(status)
    }
}

struct SanctumRealmCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(accent)
                Spacer(minLength: 8)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PersonaTheme.mercurySilver)
                Text(subtitle.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.52), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(accent.opacity(0.24))
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Enter the \(title) realm")
    }
}

struct SanctumSigil: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(PersonaTheme.mercurySilver)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial.opacity(0.30), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

struct SanctumRitualButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.callout)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(PersonaTheme.mercurySilver)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
