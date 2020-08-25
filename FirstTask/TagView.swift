import SwiftUI
import CoreData

struct TagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
       sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var tags: FetchedResults<Tag>
    @State var showingAddTagModal = false
    @State var newTagName = ""

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag.name ?? "")
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
                self.$newTagName.wrappedValue = ""
                self.showingAddTagModal = false
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
