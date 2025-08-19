import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class User: ObservableObject, Identifiable, Codable {
    let id: String
    @Published var email: String = ""
    @Published var photoURL: String = ""
    var listener: ListenerRegistration?

    var tags: [Tag] = []
    var tasks: [Task] = []
    var projects: [Project] = []

    init(id: String) {
        self.id = id
    }

    enum CodingKeys: CodingKey {
        case id, email, photoURL
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        photoURL = try container.decode(String.self, forKey: .photoURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(photoURL, forKey: .photoURL)
    }

    enum CollectionKeys: String {
        case tasks
        case tags
        case projects
    }

    var documentReference: DocumentReference {
        return Firestore.firestore().collection("users").document(id)
    }

    func collection(path: CollectionKeys) -> CollectionReference {
        return documentReference.collection(path.rawValue)
    }
}
