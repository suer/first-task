import SwiftUI
import MobileCoreServices

struct TaskList: View {
    @State var tasks: [Task]

    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRow(task: task)
            }
            .onDelete(perform: removeRow)
        }
    }

    func removeRow(offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
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
