import SwiftUI
import FirebaseAuth
import Ballcap

struct TopView: View {
    @Environment(\.managedObjectContext) var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
//    ) var tags: FetchedResults<Tag>
    @State var tags: [Tag] = [] // TODO

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
//        predicate: NSPredicate(format: "completedAt == nil")
//    ) var projects: FetchedResults<Project>
    @State var projects: [Project] = [] // TODO

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
                        task[\.projectId] == ""
                    }
                    ProjectRow(icon: "star", name: "Today") { task in
                        task.hasTagByKind(tagKind: "today")
                    }

                    Section(header: Text("Projects")) {
                        ForEach(self.projects) { project in
                            ProjectRow(icon: "flag", name: project[\.title], project: project) { task in
                                return task[\.projectId] == project.documentReference.documentID
                            }
                        }

                        Button(action: {
                            self.addingProject = Project.make(context: self.viewContext)
                            self.showingProjectAddModal.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Project")
                                Spacer()
                            }.contentShape(Rectangle())
                        }.sheet(isPresented: self.$showingProjectAddModal) {
                            ProjectAddView(project: self.addingProject)
                                .environment(\.managedObjectContext, self.viewContext)
                        }.buttonStyle(PlainButtonStyle())
                    }

                    Section(header: Text("Tags")) {
                        ForEach(tags.filter { $0[\.kind] != "today" }) { tag in
                            ProjectRow(icon: "tag", name: tag[\.name]) { task in
                                task.hasTag(tagName: tag[\.name])
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle("FirstTask")
                .navigationBarItems(
                    leading: settingButton
                )
                .onAppear {
                    let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                    user
                        .collection(path: .tags)
                        .order(by: "name")
                        .addSnapshotListener { querySnapshot, _ in
                            guard let documents = querySnapshot?.documents else {
                              return
                            }

                            self.tags = documents.map { queryDocumentSnapshot -> Tag in
                                if let tag: Tag = try? Tag(snapshot: queryDocumentSnapshot) {
                                    return tag
                                }
                                return Tag() // TODO
                            }
                        }
                    user
                        .collection(path: .projects)
                        .order(by: "title")
                        .addSnapshotListener { querySnapshot, _ in
                            guard let documents = querySnapshot?.documents else {
                              return
                            }

                            self.projects = documents.map { queryDocumentSnapshot -> Project in
                                if let project: Project = try? Project(snapshot: queryDocumentSnapshot) {
                                    return project
                                }
                                return Project() // TODO
                            }
                        }
                }
                if UIDevice.current.userInterfaceIdiom != .pad {
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
