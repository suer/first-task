import SwiftUI
import MobileCoreServices

struct TagList: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var tags: FetchedResults<Tag>
    @ObservedObject var task: Task
    @State var showAddTagModal = false
    @State var newTagName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(tags) { tag in
                    HStack {
                        Image(systemName: self.task.allTags.contains(tag) ? "checkmark.circle.fill" : "circle")
                        Text(tag.name ?? "")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if self.task.allTags.contains(tag) {
                            self.task.removeFromTags(tag)
                        } else {
                            self.task.addToTags(tag)
                        }
                    }
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FabButton {
                        self.showAddTagModal = true
                    }
                }.padding(10)
            }.padding(10)

            BottomTextFieldSheetModal(isShown: self.$showAddTagModal, text: self.$newTagName) {
                _ = Tag.create(context: self.viewContext, name: self.newTagName, task: self.task)
                self.showAddTagModal = false
                UIApplication.shared.closeKeyboard()
            }
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataSupport.context
        Tag.destroyAll(context: context)
        let tag = Tag.create(context: context, name: "重要")
        _ = Tag.create(context: context, name: "買い物")
        let task = Task.make(context: context, id: UUID(), title: "test")
        task.addToTags(tag!)
        return TagList(task: task).environment(\.managedObjectContext, context)
    }
}
