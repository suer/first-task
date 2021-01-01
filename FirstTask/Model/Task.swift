import Ballcap
import Firebase

class Task: Object, DataRepresentable, DataListenable, ObservableObject, Identifiable {
    // swiftlint:disable type_name
    typealias ID = String
    // swiftlint:enable type_name

    override class var name: String { "tasks" }
    @Published var data: Model?
    var listener: ListenerRegistration?

    struct Model: Codable, Modelable {
        var title: String = ""
        var memo: String = ""
        var completedAt: ServerTimestamp?
        var createdAt: ServerTimestamp?
        var updatedAt: ServerTimestamp?
        var startDate: ServerTimestamp?
        var dueDate: ServerTimestamp?
        var displayOrder: Int = 0
        var tagIds: OperableArray<String> = .value([])
        var projectId: String = ""
    }
}

extension Task {

    static func make(title: String) -> Task {
        let task = Task()
        task[\.title] = title
        return task
    }

    static func create(title: String) -> Task {
        let task = make(title: title)

        let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")

        let batch = Batch()
        user.tasks.append(task)
        batch.save(user.tasks, to: user.collection(path: .tasks))
        batch.commit()

        return task
    }

    static func destroy(task: Task) {
        task.delete()
    }

    func toggleDone() {
        let originalPath = self.documentReference.path
        var newPath = ""
        if self.documentReference.path.contains("/completed-tasks/") {
            newPath = originalPath.replacingOccurrences(of: "/completed-tasks/", with: "/tasks/")
        } else {
            newPath = originalPath.replacingOccurrences(of: "/tasks/", with: "/completed-tasks/")
        }
        self.save(reference: Firestore.firestore().document(newPath))
        Firestore.firestore().document(originalPath).delete()
    }

    func hasTag(tagId: String) -> Bool {
        if tagId.isEmpty {
            return true
        }
        return self[\.tagIds].contains(tagId)
    }
}
