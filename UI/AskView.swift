import SwiftUI

struct AskView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: AskViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm)
            } else {
                ProgressView()
                    .onAppear { viewModel = AskViewModel(container: container) }
            }
        }
        .navigationTitle("Ask")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ vm: AskViewModel) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Provider: \(vm.providerName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let answer = vm.lastAnswer {
                        Text(answer)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }

            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                TextField("Ask \(container.activeConfiguration.displayName)…", text: Binding(
                    get: { vm.draft },
                    set: { vm.draft = $0 }
                ), axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.roundedBorder)

                Button {
                    Task { await vm.submit() }
                } label: {
                    if vm.isProcessing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .disabled(vm.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isProcessing)
            }
            .padding()
        }
    }
}
