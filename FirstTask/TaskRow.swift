import SwiftUI

struct TaskRow: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var task: Task

    var body: some View {
        HStack {
            Circle()
                .fill(Color(task.completedAt != nil
                    ? UIColor.label
                    : UIColor.systemBackground))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.label))
                        .frame(width: 20, height: 20)
            ).onTapGesture {
                self.task.toggleDone(context: self.viewContext)
            }
            Text(task.title ?? "")
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task.make(context: CoreDataSupport.context, id: UUID(), title: "ミルクを買う"))
    }
}
