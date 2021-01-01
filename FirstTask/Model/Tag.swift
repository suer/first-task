import Ballcap
import Firebase

class Tag: Object, DataRepresentable, DataListenable, ObservableObject, Identifiable {
    // swiftlint:disable type_name
    typealias ID = String
    // swiftlint:enable type_name

    override class var name: String { "tags" }
    @Published var data: Model?
    var listener: ListenerRegistration?

    struct Model: Codable, Modelable {
        var kind: String = ""
        var name: String = ""
    }
}

extension Tag {

    static func create(name: String, kind: String? = nil, task: Task? = nil) -> Tag? {
        let tag = Tag()
        tag[\.name] = name
        tag[\.kind] = kind ?? ""

        let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")

        let batch = Batch()
        user.tags.append(tag)
        batch.save(user.tags, to: user.collection(path: .tags))
        batch.commit()

        return tag
    }

    static func destroy(tag: Tag) {
        tag.delete()
    }

}
