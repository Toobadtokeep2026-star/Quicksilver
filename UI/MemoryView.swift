import SwiftUI

struct MemoryView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: MemoryViewModel?
    @State private var draft = ""

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm)
            } else {
                ProgressView()
                    .onAppear { viewModel = MemoryViewModel(container: container) }
            }
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ vm: MemoryViewModel) -> some View {
        List {
            Section {
                HStack {
                    TextField("Quick note…", text: $draft)
                    Button("Save") {
                        Task {
                            await vm.addQuickNote(draft)
                            draft = ""
                        }
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section("Stored") {
                if vm.isLoading {
                    ProgressView()
                } else if vm.items.isEmpty {
                    Text("No memories yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.value)
                                .font(.body)
                            Text(item.updatedAt, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .task { await vm.load() }
    }
}
