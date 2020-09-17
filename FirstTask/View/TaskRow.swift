import SwiftUI

struct TaskRow: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var task: Task
    @ObservedObject var modalState: ModalState

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
            VStack {
                HStack {
                    Text(task.title ?? "")
                    Spacer()
                }
                if task.allTags.count > 0 {
                    HStack {
                        ForEach(task.allTags) { tag in
                            TagBubble(tag: tag)
                        }
                        Spacer()
                    }.padding(.top, 4)
                }
            }

        }.onTapGesture {
            self.modalState.showingEditModal.toggle()
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task.make(context: CoreDataSupport.context, id: UUID(), title: "ミルクを買う"), modalState: ModalState())
    }
}
