import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class Project: ObservableObject, Identifiable, Codable, Equatable {
    @Published var id: String = UUID().uuidString
    @Published var title: String = ""
    @Published var complatedAt: ServerTimestamp<Date>?
    @Published var createdAt: ServerTimestamp<Date>?
    @Published var updatedAt: ServerTimestamp<Date>?
    @Published var startDate: Timestamp?
    @Published var dueDate: Timestamp?
    var listener: ListenerRegistration?

    private var _documentReference: DocumentReference?

    init() {}

    enum CodingKeys: CodingKey {
        case id, title, complatedAt, createdAt, updatedAt, startDate, dueDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        complatedAt = try container.decodeIfPresent(ServerTimestamp<Date>.self, forKey: .complatedAt)
        createdAt = try container.decodeIfPresent(ServerTimestamp<Date>.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(ServerTimestamp<Date>.self, forKey: .updatedAt)
        startDate = try container.decodeIfPresent(Timestamp.self, forKey: .startDate)
        dueDate = try container.decodeIfPresent(Timestamp.self, forKey: .dueDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(complatedAt, forKey: .complatedAt)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
    }

    var documentReference: DocumentReference {
        if let ref = _documentReference {
            return ref
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            fatalError("User not authenticated")
        }
        let ref = Firestore.firestore().collection("users").document(userId).collection("projects").document(id)
        _documentReference = ref
        return ref
    }

    convenience init(snapshot: DocumentSnapshot) throws {
        self.init()
        guard let data = snapshot.data() else {
            throw NSError(domain: "ProjectError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data in snapshot"])
        }

        id = snapshot.documentID
        title = data["title"] as? String ?? ""
        complatedAt = data["complatedAt"] as? ServerTimestamp<Date>
        createdAt = data["createdAt"] as? ServerTimestamp<Date>
        updatedAt = data["updatedAt"] as? ServerTimestamp<Date>
        startDate = data["startDate"] as? Timestamp
        dueDate = data["dueDate"] as? Timestamp
        _documentReference = snapshot.reference
    }

    public var wrappedStartDate: Date {
        get { startDate?.dateValue() ?? .distantPast }
        set { startDate = Timestamp(date: newValue) }
    }

    public var useStartDate: Bool {
        get { startDate != nil }
        set {
            if newValue {
                startDate = Timestamp()
            } else {
                startDate = nil
            }
        }
    }

    public var wrappedDueDate: Date {
        get { dueDate?.dateValue() ?? .distantPast }
        set { dueDate = Timestamp(date: newValue) }
    }

    public var useDueDate: Bool {
        get { dueDate != nil }
        set {
            if newValue {
                dueDate = Timestamp()
            } else {
                dueDate = nil
            }
        }
    }
}

extension Project {

    static func destroy(project: Project) {
        project.documentReference.delete { error in
            if let error = error {
                print("Error deleting project: \(error)")
            }
        }
    }

    static func create(_ project: Project) -> Project {
        let now = Date()
        project.createdAt = ServerTimestamp(wrappedValue: now)
        project.updatedAt = ServerTimestamp(wrappedValue: now)
        do {
            try project.documentReference.setData(from: project)
        } catch {
            print("Error creating project: \(error)")
        }

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

        let newRef = Firestore.firestore().document(newPath)
        do {
            try newRef.setData(from: self)
            self.documentReference.delete()
            self._documentReference = newRef
        } catch {
            print("Error toggling project completion: \(error)")
        }
    }

    func save() {
        updatedAt = ServerTimestamp(wrappedValue: Date())
        do {
            try documentReference.setData(from: self, merge: true)
        } catch {
            print("Error saving project: \(error)")
        }
    }

    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id
    }
}
