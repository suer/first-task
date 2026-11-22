import Firebase
import FirebaseAuth
import FirebaseFirestore

enum AddInboxTaskError: Error, CustomLocalizedStringResourceConvertible {
    case notSignedIn

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notSignedIn: "Sign in to FirstTask to add tasks."
        }
    }
}

enum AddInboxTask {
    static func call(title: String, memo: String = "") async throws {
        // An intent can run in a freshly launched process before the app UI sets Firebase up.
        if !FirebaseApp.isDefaultAppConfigured() {
            FirebaseApp.configure()
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AddInboxTaskError.notSignedIn
        }

        let lastTasks = try? await User(id: uid).collection(path: .tasks)
            .order(by: "displayOrder", descending: true)
            .limit(to: 1)
            .getDocuments()
            .documents
            .compactMap { try? Task(snapshot: $0) }

        _ = Task.create(title: title, memo: memo, tasks: lastTasks ?? [])
    }
}
