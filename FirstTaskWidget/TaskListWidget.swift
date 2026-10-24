import AppIntents
import SwiftUI
import WidgetKit

struct TaskListEntry: TimelineEntry {
    enum Content {
        case signedOut
        case needsSelection(LocalizedStringResource)
        case list(title: String, tasks: [WidgetTask])
    }

    let date: Date
    let content: Content
}

struct TaskListProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TaskListEntry {
        TaskListEntry(date: .now, content: .list(title: String(localized: "Inbox"), tasks: Self.sampleTasks))
    }

    func snapshot(for configuration: TaskListIntent, in context: Context) async -> TaskListEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: TaskListIntent, in context: Context) async -> Timeline<TaskListEntry> {
        Timeline(entries: [entry(for: configuration)], policy: .never)
    }

    private func entry(for configuration: TaskListIntent) -> TaskListEntry {
        guard let snapshot = WidgetSnapshotStore.load() else {
            return TaskListEntry(date: .now, content: .signedOut)
        }

        let list = configuration.list ?? .inbox
        let content: TaskListEntry.Content =
            switch list.kind {
            case .inbox, .today:
                .list(title: list.title, tasks: snapshot.tasks(for: list.kind ?? .inbox))
            case .project(let id):
                if let project = snapshot.projects.first(where: { $0.id == id }) {
                    .list(title: project.title, tasks: snapshot.tasks(for: .project(id: id)))
                } else {
                    .needsSelection("Select a list")
                }
            case .tag(let id):
                if let tag = snapshot.tags.first(where: { $0.id == id }) {
                    .list(title: tag.name, tasks: snapshot.tasks(for: .tag(id: id)))
                } else {
                    .needsSelection("Select a list")
                }
            case nil:
                .needsSelection("Select a list")
            }
        return TaskListEntry(date: .now, content: content)
    }

    private static let sampleTasks = [
        WidgetTask(id: "1", title: "Buy milk", projectId: "", tagIds: [], displayOrder: 0),
        WidgetTask(id: "2", title: "Reply to email", projectId: "", tagIds: [], displayOrder: 1),
        WidgetTask(id: "3", title: "Book a dentist", projectId: "", tagIds: [], displayOrder: 2),
    ]
}

struct TaskListWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: TaskListEntry

    private var maxTasks: Int {
        switch family {
        case .systemSmall, .systemMedium: 4
        case .systemLarge: 10
        default: 4
        }
    }

    var body: some View {
        switch entry.content {
        case .signedOut:
            message("Open FirstTask to sync your tasks")
        case .needsSelection(let text):
            message(text)
        case .list(let title, let tasks):
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.tint)
                        .lineLimit(1)
                    Text("\(tasks.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 6)
                if tasks.isEmpty {
                    Spacer()
                    Text("No Tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    ForEach(tasks.prefix(maxTasks)) { task in
                        Text(task.title)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func message(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TaskListWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: WidgetShared.widgetKind, intent: TaskListIntent.self, provider: TaskListProvider()) { entry in
            TaskListWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Tasks")
        .description("Shows the tasks of the selected list.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
