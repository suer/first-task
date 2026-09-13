import FirebaseAuth
import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var tags: [Tag] = []

    @Binding var filteringTagName: String
    @Binding var filteringTitle: String

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: .searchByTitle), text: self.$filteringTitle)
                        .submitLabel(.search)
                        .onSubmit {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                }
                Section(header: Text(.tags)) {
                    ForEach(tags) { tag in
                        Button(action: {
                            self.filteringTagName = tag.name
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "tag")
                                Text(tag.name)
                            }
                        }
                        .accentColor(Color(.label))
                    }
                }
                Section {
                    Button(action: {
                        self.filteringTagName = ""
                        self.filteringTitle = ""
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "clear.fill")
                            Text(.reset)
                            Spacer()
                        }
                    }
                    .accentColor(Color(.label))
                }
            }
            .navigationTitle(.search)
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
        return SearchView(filteringTagName: .constant(""), filteringTitle: .constant(""))
    }
}
