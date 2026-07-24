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

            Section("Stored (by importance)") {
                if vm.isLoading {
                    ProgressView()
                } else if vm.items.isEmpty {
                    Text("No memories yet").foregroundStyle(.secondary)
                } else {
                    ForEach(vm.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.key)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                importanceBadge(item.importance)
                            }
                            Text(item.value).font(.body)
                            HStack {
                                Text(item.updatedAt, style: .relative)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                if let scope = item.personaScope {
                                    Text("· \(scope)")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .task { await vm.load() }
    }

    private func importanceBadge(_ value: Double) -> some View {
        let percent = Int(value * 100)
        let color: Color = value >= 0.7 ? .green : (value >= 0.4 ? .orange : .secondary)
        return Text("\(percent)%")
            .font(.caption2.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15), in: Capsule())
    }
}
