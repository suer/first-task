import SwiftUI

struct TopView: View {
    @Environment(\.managedObjectContext) var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var tags: FetchedResults<Tag>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        predicate: NSPredicate(format: "completedAt == nil")
    ) var projects: FetchedResults<Project>

    @State var showingSettingMenuModal = false
    @State var showingAddTaskModal = false
    @State var newTaskTitle: String = ""
    @State var showingProjectAddModal = false
    @State var addingProject: Project = Project()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ProjectRow(icon: "tray", name: "Inbox") { task in
                        task.project == nil
                    }
                    ProjectRow(icon: "star", name: "Today") { task in
                        task.hasTagByKind(tagKind: "today")
                    }

                    Section(header: Text("Projects")) {
                        ForEach(self.projects, id: \.id) { project in
                            ProjectRow(icon: "flag", name: project.title ?? "", project: project) { task in
                                if let p = task.project {
                                    return p == project
                                }
                                return false
                            }
                        }

                        Button(action: {
                            self.addingProject = Project.make(context: self.viewContext)
                            self.showingProjectAddModal.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Project")
                            }
                        }.sheet(isPresented: self.$showingProjectAddModal) {
                            ProjectAddView(project: self.addingProject)
                                .environment(\.managedObjectContext, self.viewContext)
                        }.buttonStyle(PlainButtonStyle())
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
