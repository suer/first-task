import SwiftUI

struct ProjectRow: View {
    @Binding var tasks: [Task]

    var name = ""
    var kind: WidgetListKind
    var taskListType: TaskListType
    var filter: (Task) -> Bool

    var taskCount: Int {
        self.tasks.filter { filter($0) }.count
    }

    var body: some View {
        NavigationLink(value: kind) {
            HStack {
                Image(systemName: taskListType.icon())
                Text(self.name)
                Spacer()
                Text("\(self.taskCount)")
                    .foregroundColor(.secondary)
            }
        }
    }
}
