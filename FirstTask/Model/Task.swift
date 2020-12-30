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
