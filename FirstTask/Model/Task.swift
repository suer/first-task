import Firebase
import FirebaseAuth
import FirebaseFirestore

class Task: ObservableObject, Identifiable, Codable {
    @Published var id: String = UUID().uuidString
    @Published var title: String = ""
    @Published var memo: String = ""
    @Published var completedAt: ServerTimestamp<Date>?
    @Published var createdAt: ServerTimestamp<Date>?
    @Published var updatedAt: ServerTimestamp<Date>?
    @Published var startDate: Timestamp?
    @Published var dueDate: Timestamp?
    @Published var displayOrder: Int = 0
    @Published var tagIds: [String] = []
    @Published var projectId: String = ""
    var listener: ListenerRegistration?

    private var _documentReference: DocumentReference?

    init() {}

    enum CodingKeys: CodingKey {
        case id, title, memo, completedAt, createdAt, updatedAt, startDate, dueDate, displayOrder, tagIds, projectId
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        memo = try container.decode(String.self, forKey: .memo)
        completedAt = try container.decodeIfPresent(ServerTimestamp<Date>.self, forKey: .completedAt)
        createdAt = try container.decodeIfPresent(ServerTimestamp<Date>.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(ServerTimestamp<Date>.self, forKey: .updatedAt)
        startDate = try container.decodeIfPresent(Timestamp.self, forKey: .startDate)
        dueDate = try container.decodeIfPresent(Timestamp.self, forKey: .dueDate)
        displayOrder = try container.decode(Int.self, forKey: .displayOrder)
        tagIds = try container.decode([String].self, forKey: .tagIds)
        projectId = try container.decode(String.self, forKey: .projectId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(memo, forKey: .memo)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(displayOrder, forKey: .displayOrder)
        try container.encode(tagIds, forKey: .tagIds)
        try container.encode(projectId, forKey: .projectId)
    }

    var documentReference: DocumentReference {
        if let ref = _documentReference {
            return ref
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            fatalError("User not authenticated")
        }
        let ref = Firestore.firestore().collection("users").document(userId).collection("tasks").document(id)
        _documentReference = ref
        return ref
    }

    convenience init(snapshot: DocumentSnapshot) throws {
        self.init()
        guard let data = snapshot.data() else {
            throw NSError(domain: "TaskError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data in snapshot"])
        }

        id = snapshot.documentID
        title = data["title"] as? String ?? ""
        memo = data["memo"] as? String ?? ""
        completedAt = data["completedAt"] as? ServerTimestamp<Date>
        createdAt = data["createdAt"] as? ServerTimestamp<Date>
        updatedAt = data["updatedAt"] as? ServerTimestamp<Date>
        startDate = data["startDate"] as? Timestamp
        dueDate = data["dueDate"] as? Timestamp
        displayOrder = data["displayOrder"] as? Int ?? 0
        tagIds = data["tagIds"] as? [String] ?? []
        projectId = data["projectId"] as? String ?? ""
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

extension Task {

    func allTags(tags: [Tag]) -> [Tag] {
        return tags.filter { tag in
            tagIds.contains(tag.id)
        }
    }

    func hasTagByName(tags: [Tag], name: String) -> Bool {
        guard !name.isEmpty else { return true }
        return self.allTags(tags: tags).contains { $0.name == name }
    }

    static func make(title: String, projectId: String = "", tagId: String = "") -> Task {
        let task = Task()
        task.title = title
        task.projectId = projectId
        if !tagId.isEmpty {
            task.tagIds = [tagId]
        }
        return task
    }

    static func create(title: String, projectId: String = "", tagId: String = "", tasks: [Task]) -> Task {
        let task = make(title: title, projectId: projectId, tagId: tagId)
        if let lastTask = tasks.last {
            task.displayOrder = lastTask.displayOrder + 1
        } else {
            task.displayOrder = 0
        }

        let now = Date()
        task.createdAt = ServerTimestamp(wrappedValue: now)
        task.updatedAt = ServerTimestamp(wrappedValue: now)
        do {
            try task.documentReference.setData(from: task)
        } catch {
            print("Error creating task: \(error)")
        }

        return task
    }

    static func destroy(task: Task) {
        task.documentReference.delete { error in
            if let error = error {
                print("Error deleting task: \(error)")
            }
        }
    }

    static func countTodayTasks(done: @escaping (Int) -> Void) {
        let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")

        user
            .collection(path: .tags)
            .whereField("kind", isEqualTo: "today")
            .getDocuments(completion: { snapshot, err in
                guard err == nil else { return }

                let todayTag = try? Tag(snapshot: snapshot!.documents[0])
                if let todayTag = todayTag {
                    user
                        .collection(path: .tasks)
                        .getDocuments(completion: { snapshot, err in
                            guard err == nil else { return }

                            var count = 0

                            for s in snapshot!.documents {
                                let task = try? Task(snapshot: s)
                                if let task = task {
                                    if task.tagIds.contains(todayTag.id) {
                                        count += 1
                                    }
                                }
                            }

                            done(count)
                        })
                }
            })
    }

    static func reorder(tasks: [Task], source: IndexSet, destination: Int) {
        var reordered = tasks
        reordered.move(fromOffsets: source, toOffset: destination)

        let batch = Firestore.firestore().batch()

        for (index, task) in reordered.enumerated() {
            task.displayOrder = index
            task.updatedAt = ServerTimestamp(wrappedValue: Date())
            do {
                try batch.setData(from: task, forDocument: task.documentReference, merge: true)
            } catch {
                print("Error updating task: \(error)")
            }
        }

        batch.commit { error in
            if let error = error {
                print("Error committing batch: \(error)")
            }
        }
    }

    func toggleDone() {
        let originalPath = self.documentReference.path
        var newPath = ""
        if self.documentReference.path.contains("/completed-tasks/") {
            newPath = originalPath.replacingOccurrences(of: "/completed-tasks/", with: "/tasks/")
        } else {
            newPath = originalPath.replacingOccurrences(of: "/tasks/", with: "/completed-tasks/")
        }

        let newRef = Firestore.firestore().document(newPath)
        do {
            try newRef.setData(from: self)
            self.documentReference.delete()
            self._documentReference = newRef
        } catch {
            print("Error toggling task completion: \(error)")
        }
    }

    func hasTag(tagId: String) -> Bool {
        if tagId.isEmpty {
            return true
        }
        return tagIds.contains(tagId)
    }

    func save() {
        updatedAt = ServerTimestamp(wrappedValue: Date())
        do {
            try documentReference.setData(from: self, merge: true)
        } catch {
            print("Error saving task: \(error)")
        }
    }
}
