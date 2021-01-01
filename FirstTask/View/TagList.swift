import SwiftUI
import MobileCoreServices
import FirebaseAuth
import Ballcap

struct TagList: View {
    @Environment(\.managedObjectContext) var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
//    ) var tags: FetchedResults<Tag>
    @State var tags: [Tag] = []
    @ObservedObject var task: Task
    @State var showAddTagModal = false
    @State var newTagName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(tags) { tag in
                    HStack {
                        Image(systemName: self.task.allTags.contains(tag) ? "checkmark.circle.fill" : "circle")
                        Text(tag[\.name])
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // TODO
//                        if self.task.allTags.contains(tag) {
//                            self.task.removeFromTags(tag)
//                        } else {
//                            self.task.addToTags(tag)
//                        }
                    }
                }
            }
            .navigationBarTitle("Tags", displayMode: .inline)
            .onAppear {
                let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                user
                    .collection(path: .tags)
                    .order(by: "name")
                    .addSnapshotListener { querySnapshot, _ in
                        guard let documents = querySnapshot?.documents else {
                          return
                        }

                        self.tags = documents.map { queryDocumentSnapshot -> Tag in
                            if let tag: Tag = try? Tag(snapshot: queryDocumentSnapshot) {
                                return tag
                            }
                            return Tag() // TODO
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
                _ = Tag.create(name: self.newTagName, task: self.task)
                self.showAddTagModal = false
                UIApplication.shared.closeKeyboard()
            }
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataSupport.context
        _ = Tag.create(name: "重要")
        _ = Tag.create(name: "買い物")
        let task = Task.make(title: "test")
//        task.addToTags(tag!)
        return TagList(task: task).environment(\.managedObjectContext, context)
    }
}
