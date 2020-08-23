import SwiftUI
import CoreData

struct TagView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
       sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var tags: FetchedResults<Tag>

    var body: some View {
        NavigationView {
            List {
                ForEach(tags, id: \.self) { tag in
                    Text(tag.name ?? "")
                }
                .onDelete(perform: removeRow)
            }
            .navigationBarTitle("Tags", displayMode: .inline)
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
