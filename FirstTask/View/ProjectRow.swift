import SwiftUI
import FirebaseAuth
import Ballcap

struct ProjectRow: View {
    @Binding var tasks: [Task]

    var icon = ""
    var name = ""
    var filter: (Task) -> Bool
    var project: Project?

    var taskCount: Int {
        self.tasks.filter { filter($0) }.count
    }

    init(tasks: Binding<[Task]>, icon: String, name: String, filter: @escaping (Task) -> Bool) {
        self.init(tasks: tasks, icon: icon, name: name, project: nil, filter: filter)
    }

    init(tasks: Binding<[Task]>, icon: String, name: String, project: Project?, filter: @escaping (Task) -> Bool) {
        self._tasks = tasks
        self.filter = filter
        self.icon = icon
        self.name = name
        self.project = project
    }

    var body: some View {
        HStack {
            NavigationLink(destination: TaskList(navigationBarTitle: name, filter: { task in filter(task)}, project: self.project) ) {
                Image(systemName: icon)
                Text(self.name)
                Spacer()
                Text("\(self.taskCount)")
            }
        }
    }
}
