import Ballcap
import Firebase

class Project: Object, DataRepresentable, DataListenable, ObservableObject, Identifiable {
    // swiftlint:disable type_name
    typealias ID = String
    // swiftlint:enable type_name

    override class var name: String { "projects" }
    @Published var data: Model?
    var listener: ListenerRegistration?

    struct Model: Codable, Modelable {
        var title: String = ""
        var complatedAt: ServerTimestamp?
        var createdAt: ServerTimestamp?
        var updatedAt: ServerTimestamp?
        var startDate: ServerTimestamp?
        var dueDate: ServerTimestamp?
//        var displayOrder: Int = 0
    }
}

extension Project {

    static func destroy(project: Project) {
        project.delete()
    }

    static func create(_ project: Project) -> Project {
        let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")

        let batch = Batch()
        user.projects.append(project)
        batch.save(user.projects, to: user.collection(path: .projects))
        batch.commit()

        return project
    }

    func toggleDone() {
        let originalPath = self.documentReference.path
        var newPath = ""
        if self.documentReference.path.contains("/completed-projects/") {
            newPath = originalPath.replacingOccurrences(of: "/completed-projects/", with: "/projects/")
        } else {
            newPath = originalPath.replacingOccurrences(of: "/projects/", with: "/completed-projects/")
        }
        self.save(reference: Firestore.firestore().document(newPath))
        Firestore.firestore().document(originalPath).delete()
    }
}
