import SwiftUI

@MainActor
@Observable
final class ShareModel {
    var title = ""
    var memo = ""
    var isLoading = true
    var errorMessage: LocalizedStringKey?

    private let onFinish: @MainActor (Bool) -> Void

    init(onFinish: @escaping @MainActor (Bool) -> Void) {
        self.onFinish = onFinish
    }

    var canAdd: Bool {
        !isLoading && !trimmedTitle.isEmpty
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func load(items: [NSExtensionItem]) async {
        let content = await SharedContent.load(from: items)
        title = content.title
        memo = content.url
        isLoading = false
    }

    func add() {
        guard let store = PendingTaskStore.shared else {
            errorMessage = "Could not save the task."
            return
        }
        do {
            try store.add(PendingTask(title: trimmedTitle, memo: memo.trimmingCharacters(in: .whitespacesAndNewlines)))
            onFinish(true)
        } catch {
            errorMessage = "Could not save the task."
        }
    }

    func cancel() {
        onFinish(false)
    }
}

struct ShareView: View {
    @Bindable var model: ShareModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $model.title, axis: .vertical)
                        .disabled(model.isLoading)
                }
                Section("Memo") {
                    TextField("Memo", text: $model.memo, axis: .vertical)
                        .lineLimit(3...8)
                        .disabled(model.isLoading)
                }
                Section {
                } footer: {
                    if let errorMessage = model.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    } else {
                        Text("The task will be added to the inbox when you open FirstTask.")
                    }
                }
            }
            .navigationTitle("Add to Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { model.cancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { model.add() }
                        .disabled(!model.canAdd)
                }
            }
        }
    }
}
