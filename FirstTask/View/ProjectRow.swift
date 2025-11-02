import SwiftUI

struct ProjectRow: View {
    @Binding var tasks: [Task]

    var name = ""
    var project: Project?
    var taskListType: TaskListType
    var filter: (Task) -> Bool

    var taskCount: Int {
        self.tasks.filter { filter($0) }.count
    }

    var body: some View {
        HStack {
            NavigationLink(destination: TaskList(navigationBarTitle: name, filter: { task in filter(task) }, project: self.project, taskListType: taskListType)) {
                Image(systemName: taskListType.icon())
                Text(self.name)
                Text("\(self.taskCount)")
                Spacer()
            }
        }
    }
}
