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
        var startDate: Timestamp?
        var dueDate: Timestamp?
        var displayOrder: Int = 0
        var tagIds: OperableArray<String> = .value([])
        var projectId: String = ""
    }

    public var wrappedStartDate: Date {
        get { self[\.startDate]?.dateValue() ?? .distantPast }
        set { self[\.startDate] = Timestamp(date: newValue) }
    }

    public var useStartDate: Bool {
        get { self[\.startDate] != nil }
        set {
            if newValue {
                self[\.startDate] = Timestamp()
            } else {
                self[\.startDate] = nil
            }
        }
    }

    public var wrappedDueDate: Date {
        get { self[\.dueDate]?.dateValue() ?? .distantPast }
        set { self[\.dueDate] = Timestamp(date: newValue) }
    }

    public var useDueDate: Bool {
        get { self[\.dueDate] != nil }
        set {
            if newValue {
                self[\.dueDate] = Timestamp()
            } else {
                self[\.dueDate] = nil
            }
        }
    }
}

extension Task {

    func allTags(tags: [Tag]) -> [Tag] {
        return tags.filter { tag in
            self[\.tagIds].contains { tagId in
                tag.documentReference.documentID == tagId
            }
        }
    }

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
                                    if task[\.tagIds].contains(todayTag.id) {
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

        for index in stride(from: reordered.count - 1, through: 0, by: -1) {
            reordered[index][\.displayOrder] = index
        }

        let batch = Batch()
        for task in reordered {
            batch.update(task)
        }
        batch.commit()
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
