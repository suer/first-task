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
            }
            .navigationBarTitle("Tags", displayMode: .inline)
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView()
    }
}
