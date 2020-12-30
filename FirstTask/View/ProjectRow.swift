import SwiftUI
import FirebaseAuth
import Ballcap

struct ProjectRow: View {
    @Environment(\.managedObjectContext) var viewContext

    @State var taskCount: Int = 0

    var icon = ""
    var name = ""
    var filter: (Task) -> Bool
    var project: Project?

    init(icon: String, name: String, filter: @escaping (Task) -> Bool) {
        self.init(icon: icon, name: name, project: nil, filter: filter)
    }

    init(icon: String, name: String, project: Project?, filter: @escaping (Task) -> Bool) {
        self.filter = filter
        self.icon = icon
        self.name = name
        self.project = project
    }

    var body: some View {
        HStack {
            NavigationLink(destination: TaskList(navigationBarTitle: name, filter: { task in filter(task)}, project: self.project) ) {
                Image(systemName: icon)
                Text(self.name)
                Spacer()
                Text("\(self.taskCount)")
            }
            .onAppear {
                let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                // TODO: today row
                // TODO: complatedAt
                user
                    .collection(path: .tasks)
                    .whereField("projectId", isEqualTo: project?.documentReference.documentID ?? "")
                    .addSnapshotListener { querySnapshot, _ in
                        guard let documents = querySnapshot?.documents else {
                            return
                        }

                        self.taskCount = documents.count
                    }
            }
        }
    }
}

struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ProjectRow(icon: "tray", name: "Inbox") { _ in true }
                    .environment(\.managedObjectContext, CoreDataSupport.context)
                ProjectRow(icon: "star", name: "Today") { _ in true }
                    .environment(\.managedObjectContext, CoreDataSupport.context)
            }
        }
    }
}
