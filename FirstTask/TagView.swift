import SwiftUI
import CoreData

struct TagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
       sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var tags: FetchedResults<Tag>
    @State var showingActionSheet: Bool = false
    @State var showingAddTagModal = false
    @State var showingEditTagModal = false
    @State var newTagName = ""
    @State var editingTag: Tag = Tag()

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Text(tag.name ?? "")
                            Spacer()
                            Button(action: {
                                self.showingActionSheet = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }.actionSheet(isPresented: self.$showingActionSheet) {
                                ActionSheet(title: Text(tag.name ?? ""),
                                    buttons: [
                                        .default(Text("Edit")) {
                                            self.newTagName = tag.name ?? ""
                                            self.editingTag = tag
                                            self.showingEditTagModal = true
                                        },
                                        .destructive(Text("Delete")) {
                                            Tag.destroy(context: self.viewContext, tag: tag)
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
            }
            BottomTextFieldSheetModal(isShown: self.$showingAddTagModal, text: self.$newTagName) {
                _ = Tag.create(context: self.viewContext, name: self.newTagName)
                self.showingAddTagModal = false
            }
            BottomTextFieldSheetModal(isShown: self.$showingEditTagModal, text: self.$newTagName) {
                self.editingTag.name = self.newTagName
                self.showingEditTagModal = false
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        offsets.forEach { i in
            Tag.destroy(context: self.viewContext, tag: tags[i])
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView()
    }
}
