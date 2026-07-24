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
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        Text("Provider: \(vm.providerName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(vm.turns) { turn in
                            turnBubble(turn)
                                .id(turn.id)
                        }

                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.turns.count) { _, _ in
                    if let last = vm.turns.last?.id {
                        withAnimation {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
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
        .task { await vm.loadHistory() }
    }

    private func turnBubble(_ turn: ChatTurn) -> some View {
        HStack {
            if turn.role == .user { Spacer(minLength: 40) }
            Text(turn.text)
                .font(.body)
                .padding(12)
                .background(
                    turn.role == .user
                        ? Color.accentColor.opacity(0.15)
                        : Color.secondary.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
            if turn.role == .assistant { Spacer(minLength: 40) }
        }
    }
}
