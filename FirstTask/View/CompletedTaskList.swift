import FirebaseAuth
import SwiftUI

struct CompletedTaskList: View {
    private struct MonthGroup: Identifiable {
        let id: String
        let title: String
        let tasks: [Task]
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyyMM")
        return formatter
    }()

    @EnvironmentObject var appSettings: AppSettings

    @State var tasks: [Task] = []
    @State var isLoadingTasks = true

    private var groupedTasks: [MonthGroup] {
        var tasksByMonth: [DateComponents: [Task]] = [:]
        var monthOrder: [DateComponents] = []
        var unknownTasks: [Task] = []

        for task in self.tasks {
            guard let completedAt = task.completedAt?.wrappedValue else {
                unknownTasks.append(task)
                continue
            }
            let components = Calendar.current.dateComponents([.year, .month], from: completedAt)
            if tasksByMonth[components] == nil {
                monthOrder.append(components)
            }
            tasksByMonth[components, default: []].append(task)
        }

        var groups = monthOrder.map { components in
            MonthGroup(
                id: "\(components.year ?? 0)-\(components.month ?? 0)",
                title: Calendar.current.date(from: components).map { Self.monthFormatter.string(from: $0) } ?? "",
                tasks: tasksByMonth[components] ?? []
            )
        }

        if !unknownTasks.isEmpty {
            groups.append(MonthGroup(id: "unknown", title: String(localized: .unknown), tasks: unknownTasks))
        }

        return groups
    }

    var body: some View {
        Group {
            if self.isLoadingTasks {
                ProgressView()
            } else if self.tasks.isEmpty {
                ContentUnavailableView {
                    Label(.noCompletedTasks, systemImage: "checkmark.circle")
                } description: {
                    Text(.tasksYouCompleteWillAppearHere)
                }
            } else {
                List {
                    ForEach(self.groupedTasks) { group in
                        Section(header: Text(group.title)) {
                            ForEach(group.tasks) { task in
                                TaskRow(task: task)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        task.toggleDone()
                                    }
                            }
                            .onDelete { offsets in
                                self.removeRow(tasks: group.tasks, offsets: offsets)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(.completedTasks)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
            user
                .collection(path: .completedTasks)
                .addSnapshotListener { querySnapshot, _ in
                    guard let documents = querySnapshot?.documents else { return }

                    self.tasks = documents.map { queryDocumentSnapshot -> Task? in
                        return try? Task(snapshot: queryDocumentSnapshot)
                    }.compactMap { $0 }
                        .sorted { ($0.completedAt?.wrappedValue ?? .distantPast) > ($1.completedAt?.wrappedValue ?? .distantPast) }
                    self.isLoadingTasks = false
                }
        }
    }

    func removeRow(tasks: [Task], offsets: IndexSet) {
        for i in offsets {
            Task.destroy(task: tasks[i])
        }
    }
}

struct CompletedTaskList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CompletedTaskList()
                .environmentObject(AppSettings())
        }
    }
}
