import SwiftUI
import MobileCoreServices

struct TagList: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var task: Task
    @State var showAddTagModal = false
    @State var newTagName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(task.allTags) { tag in
                    Text(tag.name ?? "")
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
            }
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataSupport.context
        return TagList(task: Task.make(context: context, id: UUID(), title: "test")).environment(\.managedObjectContext, context)
    }
}
