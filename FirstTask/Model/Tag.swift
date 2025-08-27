import Firebase
import FirebaseFirestore
import FirebaseAuth

class Tag: ObservableObject, Identifiable, Codable, Hashable {
    @Published var id: String = UUID().uuidString
    @Published var kind: String = ""
    @Published var name: String = ""
    var listener: ListenerRegistration?

    private var _documentReference: DocumentReference?

    init() {}

    enum CodingKeys: CodingKey {
        case id, kind, name
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        kind = try container.decode(String.self, forKey: .kind)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kind, forKey: .kind)
        try container.encode(name, forKey: .name)
    }

    var documentReference: DocumentReference {
        if let ref = _documentReference {
            return ref
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            fatalError("User not authenticated")
        }
        let ref = Firestore.firestore().collection("users").document(userId).collection("tags").document(id)
        _documentReference = ref
        return ref
    }

    convenience init(snapshot: DocumentSnapshot) throws {
        self.init()
        guard let data = snapshot.data() else {
            throw NSError(domain: "TagError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data in snapshot"])
        }

        id = snapshot.documentID
        kind = data["kind"] as? String ?? ""
        name = data["name"] as? String ?? ""
        _documentReference = snapshot.reference
    }

    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Tag {

    static func create(name: String, kind: String? = nil, task: Task? = nil) -> Tag? {
        let tag = Tag()
        tag.name = name
        tag.kind = kind ?? ""

        do {
            try tag.documentReference.setData(from: tag)
        } catch {
            print("Error creating tag: \(error)")
            return nil
        }

        return tag
    }

    static func destroy(tag: Tag) {
        tag.documentReference.delete { error in
            if let error = error {
                print("Error deleting tag: \(error)")
            }
        }
    }

    func save() {
        do {
            try documentReference.setData(from: self, merge: true)
        } catch {
            print("Error saving tag: \(error)")
        }
    }

}
