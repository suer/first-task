import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct TagList: View {
    @EnvironmentObject var appSettings: AppSettings

    @ObservedObject var task: Task
    @State var showAddTagModal = false
    @State var newTagName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(appSettings.tags) { tag in
                    HStack {
                        Image(systemName: self.task.allTags(tags: appSettings.tags).contains(tag) ? "checkmark.circle.fill" : "circle")
                        Text(tag.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if self.task.allTags(tags: appSettings.tags).contains(tag) {
                            self.task.tagIds = self.task.tagIds.filter { tagId in tagId != tag.id }
                        } else {
                            self.task.tagIds.append(tag.id)
                        }
                        self.task.save()
                    }
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                user
                    .collection(path: .tags)
                    .order(by: "name")
                    .addSnapshotListener { querySnapshot, _ in
                        guard let documents = querySnapshot?.documents else { return }

                        self.appSettings.tags = documents.map { queryDocumentSnapshot -> Tag? in
                            return try? Tag(snapshot: queryDocumentSnapshot)
                        }.compactMap { $0 }
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
        _ = Tag.create(name: "重要")
        _ = Tag.create(name: "買い物")
        let task = Task.make(title: "test")
        return TagList(task: task)
    }
}
