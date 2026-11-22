import FirebaseAuth

// Moves tasks queued by the share extension into the inbox.
@MainActor
enum ImportPendingTasks {
    private static var isRunning = false

    static func call() async {
        guard !isRunning, Auth.safeAuth()?.currentUser != nil, let store = PendingTaskStore.shared else { return }
        isRunning = true
        defer { isRunning = false }

        for pendingTask in store.load() {
            do {
                try await AddInboxTask.call(title: pendingTask.title, memo: pendingTask.memo)
                store.remove(pendingTask)
            } catch {
                print("Error importing pending task: \(error)")
                return
            }
        }
    }
}
