import SwiftUI

struct TopView: View {
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        NavigationView {
            List {
                ProjectRow(icon: "tray", name: "Inbox") { _ in
                    true // XXX has no projects
                }
                ProjectRow(icon: "star", name: "Today") { task in
                    task.hasTagByKind(tagKind: "today")
                }

                Section(header: Text("Projects")) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Project")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("FirstTask")
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environment(\.managedObjectContext, CoreDataSupport.context)
    }
}
