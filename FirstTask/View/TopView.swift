import SwiftUI

struct TopView: View {
    @Environment(\.managedObjectContext) var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var tags: FetchedResults<Tag>

    @State var showingSettingMenuModal = false
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

                    Section(header: Text("Tags")) {
                        ForEach(tags.filter { $0.kind != "today" }) { tag in
                            ProjectRow(icon: "tag", name: tag.name ?? "") { task in
                                task.hasTag(tagName: tag.name ?? "")
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle("FirstTask")
                .navigationBarItems(
                    leading: settingButton
                )

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

    private var settingButton: some View {
        Button(action: {
            self.showingSettingMenuModal = true
        }) {
            Image(systemName: "gear")
                .frame(width: 40, height: 40)
                .imageScale(.large)
                .clipShape(Circle())
        }.sheet(isPresented: self.$showingSettingMenuModal, onDismiss: {
            self.showingSettingMenuModal = false
        }) {
            SettingMenuView().environment(\.managedObjectContext, self.viewContext)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environment(\.managedObjectContext, CoreDataSupport.context)
    }
}
