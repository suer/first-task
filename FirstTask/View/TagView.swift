import SwiftUI
import FirebaseAuth
import Ballcap

struct TagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var appSettings: AppSettings

    @State var showingActionSheet: Bool = false
    @State var showingAddTagModal = false
    @State var showingEditTagModal = false
    @State var newTagName = ""
    @State var editingTag: Tag = Tag()

    var body: some View {
        ZStack {
            List {
                ForEach(appSettings.tags, id: \.self) { tag in
                    HStack {
                        Text(tag[\.name])
                        Spacer()
                        Button(action: {
                            self.editingTag = tag
                            self.showingActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }.actionSheet(isPresented: self.$showingActionSheet) {
                            ActionSheet(title: Text(self.editingTag[\.name]),
                                buttons: [
                                    .default(Text("Edit")) {
                                        self.newTagName = self.editingTag[\.name]
                                        self.showingEditTagModal = true
                                    },
                                    .destructive(Text("Delete")) {
                                        Tag.destroy(tag: self.editingTag)
                                    },
                                    .cancel(Text("Cancel"))
                            ])
                        }
                    }
                }
                .onDelete(perform: removeRow)
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingAddTagModal.toggle()
                    }) {
                        Text("Add new tag")
                    }
                    Spacer()
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

                        self.appSettings.tags = documents.map { queryDocumentSnapshot -> Tag in
                            if let tag: Tag = try? Tag(snapshot: queryDocumentSnapshot) {
                                return tag
                            }
                            return Tag() // TODO
                        }
                    }
            }
            BottomTextFieldSheetModal(isShown: self.$showingAddTagModal, text: self.$newTagName) {
                _ = Tag.create(name: self.newTagName)
                self.showingAddTagModal = false
                UIApplication.shared.closeKeyboard()
            }
            BottomTextFieldSheetModal(isShown: self.$showingEditTagModal, text: self.$newTagName) {
                let batch = Batch()
                self.editingTag[\.name] = self.newTagName
                batch.update(self.editingTag)
                batch.commit()
                self.showingEditTagModal = false
                UIApplication.shared.closeKeyboard()
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        offsets.forEach { i in
            Tag.destroy(tag: appSettings.tags[i])
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView().environment(\.managedObjectContext, CoreDataSupport.context)
    }
}
