import SwiftUI
import FirebaseAuth
import Ballcap

struct TopView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var projects: [Project] = []
    @State var tasks: [Task] = []

    @State var showingSettingMenuModal = false
    @State var showingAddTaskModal = false
    @State var newTaskTitle: String = ""
    @State var showingProjectAddModal = false
    @State var addingProject: Project = Project()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ProjectRow(tasks: self.$tasks, icon: "tray", name: "Inbox") { task in
                        task[\.projectId] == ""
                    }
                    ProjectRow(tasks: self.$tasks, icon: "star", name: "Today") { task in
                        task.hasTag(tagId: todayTagId)
                    }

                    Section(header: Text("Projects")) {
                        ForEach(self.projects) { project in
                            ProjectRow(tasks: self.$tasks, icon: "flag", name: project[\.title], project: project) { task in
                                return task[\.projectId] == project.documentReference.documentID
                            }
                        }

                        Button(action: {
                            self.addingProject = Project()
                            self.showingProjectAddModal.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Project")
                                Spacer()
                            }.contentShape(Rectangle())
                        }.sheet(isPresented: self.$showingProjectAddModal) {
                            ProjectAddView(project: self.addingProject)
                        }.buttonStyle(PlainButtonStyle())
                    }

                    Section(header: Text("Tags")) {
                        ForEach(appSettings.tags.filter { $0[\.kind] != "today" }) { tag in
                            ProjectRow(tasks: self.$tasks, icon: "tag", name: tag[\.name]) { task in
                                task.hasTag(tagId: tag.id)
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
                            guard let documents = querySnapshot?.documents else { return }

                            self.appSettings.tags = documents.map { queryDocumentSnapshot -> Tag? in
                                return try? Tag(snapshot: queryDocumentSnapshot)
                            }.compactMap { $0 }
                        }
                    user
                        .collection(path: .projects)
                        .order(by: "title")
                        .addSnapshotListener { querySnapshot, _ in
                            guard let documents = querySnapshot?.documents else { return }

                            self.projects = documents.map { queryDocumentSnapshot -> Project? in
                                return try? Project(snapshot: queryDocumentSnapshot)
                            }.compactMap { $0 }
                        }
                    user
                        .collection(path: .tasks)
                        .addSnapshotListener { querySnapshot, _ in
                            guard let documents = querySnapshot?.documents else { return }

                            self.tasks = documents.map { queryDocumentSnapshot -> Task? in
                                return try? Task(snapshot: queryDocumentSnapshot)
                            }.compactMap { $0 }
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
                        _ = Task.create(title: self.$newTaskTitle.wrappedValue)
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
            SettingMenuView()
        }
    }

    private var todayTagId: String {
        self.appSettings.tags.first { $0[\.kind] == "today" }?.id ?? ""
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
