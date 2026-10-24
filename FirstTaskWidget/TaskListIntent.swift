import AppIntents

struct TaskListEntity: AppEntity {
    static let inboxID = "inbox"
    static let todayID = "today"
    private static let projectPrefix = "project:"
    private static let tagPrefix = "tag:"

    let id: String
    let title: String

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "List"
    static let defaultQuery = TaskListQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    var kind: WidgetListKind? {
        switch id {
        case Self.inboxID: .inbox
        case Self.todayID: .today
        case _ where id.hasPrefix(Self.projectPrefix): .project(id: String(id.dropFirst(Self.projectPrefix.count)))
        case _ where id.hasPrefix(Self.tagPrefix): .tag(id: String(id.dropFirst(Self.tagPrefix.count)))
        default: nil
        }
    }

    static var inbox: TaskListEntity {
        TaskListEntity(id: inboxID, title: String(localized: "Inbox"))
    }

    static var today: TaskListEntity {
        TaskListEntity(id: todayID, title: String(localized: "Today"))
    }

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    init(project: WidgetProject) {
        self.init(id: Self.projectPrefix + project.id, title: project.title)
    }

    init(tag: WidgetTag) {
        self.init(id: Self.tagPrefix + tag.id, title: tag.name)
    }

    static func all(in snapshot: WidgetSnapshot?) -> [TaskListEntity] {
        [inbox, today]
            + (snapshot?.projects ?? []).sorted { $0.title < $1.title }.map { TaskListEntity(project: $0) }
            + (snapshot?.tags ?? []).filter { $0.kind != "today" }.sorted { $0.name < $1.name }.map { TaskListEntity(tag: $0) }
    }
}

struct TaskListQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TaskListEntity] {
        TaskListEntity.all(in: WidgetSnapshotStore.load()).filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> IntentItemCollection<TaskListEntity> {
        let snapshot = WidgetSnapshotStore.load()
        let projects = (snapshot?.projects ?? []).sorted { $0.title < $1.title }.map { TaskListEntity(project: $0) }
        let tags = (snapshot?.tags ?? []).filter { $0.kind != "today" }.sorted { $0.name < $1.name }.map { TaskListEntity(tag: $0) }

        var sections = [IntentItemSection(items: [TaskListEntity.inbox, TaskListEntity.today].map { IntentItem($0) })]
        if !projects.isEmpty {
            sections.append(IntentItemSection("Projects", items: projects))
        }
        if !tags.isEmpty {
            sections.append(IntentItemSection("Tags", items: tags))
        }
        return IntentItemCollection(sections: sections)
    }
}

struct TaskListIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Tasks"
    static let description = IntentDescription("Shows the tasks of the selected list.")

    @Parameter(title: "List", default: TaskListEntity.inbox)
    var list: TaskListEntity?
}
