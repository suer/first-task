import SwiftUI

struct TaskRow: View {
    var task: Task
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(task.completed
                    ? UIColor.label
                    : UIColor.systemBackground))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.label))
                        .frame(width: 20, height: 20)
            ).onTapGesture {
                self.task.completed.toggle()
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
