import SwiftUI

struct LinkedTaskList: View {
    let kind: WidgetListKind
    let projects: [Project]
    let tags: [Tag]

    static func canResolve(_ kind: WidgetListKind, projects: [Project], tags: [Tag]) -> Bool {
        switch kind {
        case .inbox: true
        case .today: tags.contains { $0.kind == "today" }
        case .project(let id): projects.contains { $0.id == id }
        case .tag(let id): tags.contains { $0.id == id }
        }
    }

    var body: some View {
        switch kind {
        case .inbox:
            TaskList(navigationBarTitle: String(localized: .inbox), filter: { $0.projectId == "" }, taskListType: .inbox)
        case .today:
            let todayTagId = tags.first { $0.kind == "today" }?.id ?? ""
            TaskList(navigationBarTitle: String(localized: .today), filter: { $0.hasTag(tagId: todayTagId) }, taskListType: .today)
        case .project(let id):
            if let project = projects.first(where: { $0.id == id }) {
                TaskList(navigationBarTitle: project.title, filter: { $0.projectId == project.id }, project: project, taskListType: .project)
            }
        case .tag(let id):
            if let tag = tags.first(where: { $0.id == id }) {
                TaskList(navigationBarTitle: tag.name, filter: { $0.hasTag(tagId: tag.id) }, taskListType: .tag)
            }
        }
    }
}
