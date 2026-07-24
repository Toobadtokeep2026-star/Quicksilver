import SwiftUI

/// Root content view.
/// Day One: simple shell that surfaces the active persona and Nexus status.
/// Follows HIG: clear hierarchy, readable typography, sufficient contrast, no decorative noise.
struct ContentView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                personaHeader
                nexusStatusCard
                Spacer()
                versionFooter
            }
            .padding()
            .navigationTitle("Quicksilver")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                container.nexus.start()
            }
        }
    }

    private var personaHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(container.activePersona.name)
                .font(.largeTitle.weight(.semibold))
            Text(container.activePersona.shortDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var nexusStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Nexus", systemImage: "antenna.radiowaves.left.and.right")
                .font(.headline)

            HStack {
                Circle()
                    .fill(container.nexus.isActive ? .green : .secondary)
                    .frame(width: 8, height: 8)
                Text(container.nexus.isActive ? "Active" : "Inactive")
                    .font(.subheadline)
            }

            Text("System & network monitoring foundation ready.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var versionFooter: some View {
        Text("v\(container.configuration.fullVersionString)")
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }
}

#Preview {
    ContentView()
        .environment(DependencyContainer())
}
