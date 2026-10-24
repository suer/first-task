import FirebaseAuth
import FirebaseFirestore
import WidgetKit

enum SyncWidgetSnapshot {
    static func call(tasks: [Task], projects: [Project], tags: [Tag]) {
        save(WidgetSnapshot(tasks: tasks, projects: projects, tags: tags))
    }

    static func clear() {
        WidgetSnapshotStore.clear()
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetShared.widgetKind)
    }

    static func fetchAndSave() async throws {
        guard let uid = Auth.safeAuth()?.currentUser?.uid else { return }

        let user = User(id: uid)
        let tasksCollection = user.collection(path: .tasks)
        let projectsCollection = user.collection(path: .projects)
        let tagsCollection = user.collection(path: .tags)
        async let tasks = tasksCollection.getDocuments()
        async let projects = projectsCollection.getDocuments()
        async let tags = tagsCollection.getDocuments()

        let snapshot = WidgetSnapshot(
            tasks: try await tasks.documents.compactMap { try? Task(snapshot: $0) },
            projects: try await projects.documents.compactMap { try? Project(snapshot: $0) },
            tags: try await tags.documents.compactMap { try? Tag(snapshot: $0) }
        )
        save(snapshot)
    }

    private static func save(_ snapshot: WidgetSnapshot) {
        guard WidgetSnapshotStore.load() != snapshot else { return }
        WidgetSnapshotStore.save(snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetShared.widgetKind)
    }
}

extension WidgetSnapshot {
    fileprivate init(tasks: [Task], projects: [Project], tags: [Tag]) {
        self.init(
            tasks: tasks.map {
                WidgetTask(id: $0.id, title: $0.title, projectId: $0.projectId, tagIds: $0.tagIds, displayOrder: $0.displayOrder)
            },
            projects: projects.map { WidgetProject(id: $0.id, title: $0.title) },
            tags: tags.map { WidgetTag(id: $0.id, name: $0.name, kind: $0.kind) }
        )
    }
}
