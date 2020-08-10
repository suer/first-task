import SwiftUI

struct TaskRow: View {
    var task: Task
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(task.completed
                    ? UIColor.darkText
                    : UIColor.systemBackground))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.darkText))
                        .frame(width: 20, height: 20)
            ).onTapGesture {
                self.task.completed = !self.task.completed
            }
            Text(task.title ?? "")
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task.make(id: UUID(), title: "ミルクを買う"))
    }
}
