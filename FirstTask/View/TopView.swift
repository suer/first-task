import SwiftUI

struct TopView: View {
    @Environment(\.managedObjectContext) var viewContext

    @State var showingAddTaskModal = false
    @State var newTaskTitle: String = ""

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
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

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FabButton {
                            self.showingAddTaskModal = true
                        }
                    }.padding(10)
                }.padding(10)

                BottomTextFieldSheetModal(isShown: self.$showingAddTaskModal, text: self.$newTaskTitle) {
                    _ = Task.create(context: self.viewContext, title: self.$newTaskTitle.wrappedValue)
                    self.showingAddTaskModal = false
                }
            }
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environment(\.managedObjectContext, CoreDataSupport.context)
    }
}
