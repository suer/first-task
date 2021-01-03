import SwiftUI
import FirebaseAuth

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode

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
        }.onAppear {
            User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                .collection(path: .tags)
                .order(by: "name")
                .addSnapshotListener { querySnapshot, _ in
                    guard let documents = querySnapshot?.documents else { return }

                    self.tags = documents.map { queryDocumentSnapshot -> Tag? in
                        return try? Tag(snapshot: queryDocumentSnapshot)
                    }.compactMap { $0 }
                }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        _ = Tag.create(name: "買い物")
        return SearchView(filteringTagName: .constant(""))
    }
}
