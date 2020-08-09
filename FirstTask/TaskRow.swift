import SwiftUI

struct TaskRow: View {
    var task: Task

    var body: some View {
        Text(task.title ?? "")
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task.make(id: UUID(), title: "ミルクを買う"))
    }
}
