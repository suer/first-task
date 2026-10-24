import Foundation

enum WidgetShared {
    static let appGroupIdentifier = "group.org.codefirst.FirstTaskExtension"
    static let widgetKind = "TaskListWidget"
}

struct WidgetTask: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let title: String
    let projectId: String
    let tagIds: [String]
    let displayOrder: Int
}

struct WidgetProject: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let title: String
}

struct WidgetTag: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let name: String
    let kind: String
}

enum WidgetListKind: Sendable {
    case inbox
    case today
    case project(id: String)
    case tag(id: String)
}

struct WidgetSnapshot: Codable, Equatable, Sendable {
    var tasks: [WidgetTask]
    var projects: [WidgetProject]
    var tags: [WidgetTag]

    var todayTagId: String? {
        tags.first { $0.kind == "today" }?.id
    }

    func tasks(for kind: WidgetListKind) -> [WidgetTask] {
        let matched = tasks.filter { task in
            switch kind {
            case .inbox:
                task.projectId.isEmpty
            case .today:
                todayTagId.map { task.tagIds.contains($0) } ?? false
            case .project(let id):
                task.projectId == id
            case .tag(let id):
                task.tagIds.contains(id)
            }
        }
        return matched.sorted { $0.displayOrder < $1.displayOrder }
    }
}

enum WidgetSnapshotStore {
    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: WidgetShared.appGroupIdentifier)?
            .appendingPathComponent("widget-snapshot.json")
    }

    static func load() -> WidgetSnapshot? {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static func save(_ snapshot: WidgetSnapshot) {
        guard let url = fileURL else { return }
        do {
            try JSONEncoder().encode(snapshot).write(to: url, options: .atomic)
        } catch {
            print("Error saving widget snapshot: \(error)")
        }
    }

    static func clear() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
