import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct TagView: View {
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
                        Text(tag.name)
                        Spacer()
                        Button(action: {
                            self.editingTag = tag
                            self.showingActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                }
                .onDelete(perform: removeRow)
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingAddTagModal.toggle()
                    }) {
                        Text(.addNewTag)
                    }
                    Spacer()
                }
            }.confirmationDialog(
                self.editingTag.name,
                isPresented: self.$showingActionSheet,
                titleVisibility: .visible
            ) {
                Button(.edit) {
                    self.newTagName = self.editingTag.name
                    self.showingEditTagModal = true
                }
                Button(.delete, role: .destructive) {
                    Tag.destroy(tag: self.editingTag)
                }
            }
            .navigationTitle(.tags)
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
            BottomTextFieldSheetModal(isShown: self.$showingAddTagModal, text: self.$newTagName) {
                _ = Tag.create(name: self.newTagName)
                self.showingAddTagModal = false
                UIApplication.shared.closeKeyboard()
            }
            BottomTextFieldSheetModal(isShown: self.$showingEditTagModal, text: self.$newTagName) {
                self.editingTag.name = self.newTagName
                self.editingTag.save()
                self.showingEditTagModal = false
                UIApplication.shared.closeKeyboard()
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        for i in offsets {
            Tag.destroy(tag: appSettings.tags[i])
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView()
    }
}
