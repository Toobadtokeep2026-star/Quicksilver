import SwiftUI

/// The Codex: governance of Mercury himself, not a generic settings screen.
struct CodexView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: SettingsViewModel(container: container))
    }

    var body: some View {
        Form {
            Section {
                Toggle("Intelligence Active", isOn: Binding(
                    get: { viewModel.aiEnabled },
                    set: { viewModel.setAIEnabled($0) }
                ))
                LabeledContent("Vessel", value: viewModel.providerName)
                LabeledContent("Key bound", value: viewModel.hasStoredKey ? "Yes — Keychain" : "Unbound")
            } header: {
                Text("Mind")
            } footer: {
                Text("Credentials remain sealed in the device Keychain.")
            }

            Section {
                Toggle("Autonomous Persona Shifts", isOn: Binding(
                    get: { viewModel.personaAutonomyEnabled },
                    set: { viewModel.setPersonaAutonomy($0) }
                ))
                if let reason = viewModel.lastSwitchReason {
                    LabeledContent("Last shift", value: reason)
                }
            } header: {
                Text("Identity")
            }

            Section {
                SecureField("Bind xAI key", text: Binding(
                    get: { viewModel.apiKeyDraft },
                    set: { viewModel.apiKeyDraft = $0 }
                ))
                .textContentType(.password)
                .autocorrectionDisabled()

                Button("Bind Key") { viewModel.saveAPIKey() }
                    .disabled(viewModel.apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if viewModel.hasStoredKey {
                    Button("Unbind Key", role: .destructive) { viewModel.clearAPIKey() }
                }
            } header: {
                Text("Covenant")
            }

            if let message = viewModel.statusMessage {
                Section {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(viewModel.statusIsError ? .red : .secondary)
                }
            }

            Section {
                LabeledContent("Version", value: container.configuration.fullVersionString)
                LabeledContent("Realm", value: "Sanctum")
            } header: {
                Text("Record")
            }
        }
        .scrollContentBackground(.hidden)
        .background(PersonaTheme.cosmicBlack)
        .navigationTitle("The Codex")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Seal") { dismiss() }
            }
        }
        .preferredColorScheme(.dark)
        .task { viewModel.refresh() }
    }
}
