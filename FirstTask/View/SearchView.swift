import SwiftUI

struct SearchView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
//    ) var tags: FetchedResults<Tag>
    @State var tags: [Tag] = []

    @Binding var filteringTagName: String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tags")) {
                    Button(action: {
                        self.filteringTagName = ""
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "clear.fill")
                            Text("Reset")
                            Spacer()
                        }
                    }
                    .accentColor(Color(UIColor.label))

                    ForEach(tags) { tag in
                        Button(action: {
                            self.filteringTagName = tag[\.name]
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "tag")
                                Text(tag[\.name])
                            }
                        }
                        .accentColor(Color(UIColor.label))
                    }
                }
            }
            .navigationBarTitle("Search")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataSupport.context
        _ = Tag.create(name: "買い物")
        return SearchView(filteringTagName: .constant("")).environment(\.managedObjectContext, context)
    }
}
