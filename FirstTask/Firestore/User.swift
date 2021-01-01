import Ballcap
import Firebase

class User: Object, DataRepresentable & HierarchicalStructurable, DataListenable, ObservableObject, Identifiable {
    // swiftlint:disable type_name
    typealias ID = String
    // swiftlint:enable type_name

    override class var name: String { "users" }
    @Published var data: Model?
    var listener: ListenerRegistration?

    var tags: [Tag] = []

    struct Model: Codable, Modelable {
        var email: String = ""
        var photoURL: String = ""
    }

    enum CollectionKeys: String {
        case tasks
        case tags
        case projects
    }
}
