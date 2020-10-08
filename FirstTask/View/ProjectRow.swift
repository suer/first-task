import SwiftUI

struct ProjectRow: View {
    @Environment(\.managedObjectContext) var viewContext

    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.displayOrder, ascending: true)],
        predicate: NSPredicate(format: "completedAt == nil")
    ) var tasks: FetchedResults<Task>

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
                Text("\(self.tasks.filter { self.filter($0) }.count)")
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
