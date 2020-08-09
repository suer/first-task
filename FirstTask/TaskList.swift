import SwiftUI

struct TaskList: View {
    var tasks: [Task]

    var body: some View {
        List(tasks) { task in
            TaskRow(task: task)
        }
    }
}

struct TaskList_Previews: PreviewProvider {
    static var previews: some View {
        TaskList(
            tasks: [
                Task(id: 1, title: "ミルクを買う"),
                Task(id: 2, title: "メールを返す")
        ])
    }
}
