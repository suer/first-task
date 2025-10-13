import SwiftUI
import FirebaseAuth

struct TopView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var projects: [Project] = []
    @State var tasks: [Task] = []

    @State var showingSettingMenuModal = false
    @State var showingAddTaskModal = false
    @State var newTaskTitle: String = ""
    @State var showingProjectAddModal = false
    @State var addingProject: Project = Project()
    @State var showingFabButton = false

    @ObservedObject private var sessionState = SessionState()
    @State var showingFirebaseUIView = false
    @State private var showingSignOutConfirm = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ProjectRow(tasks: self.$tasks, name: "Inbox", taskListType: .inbox) { task in
                        task.projectId == ""
                    }
                    ProjectRow(tasks: self.$tasks, name: "Today", taskListType: .today) { task in
                        task.hasTag(tagId: todayTagId)
                    }

                    Section(header: Text("Projects")) {
                        ForEach(self.projects) { project in
                            ProjectRow(tasks: self.$tasks, name: project.title, project: project, taskListType: .project) { task in
                                return task.projectId == project.documentReference.documentID
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
                        ForEach(appSettings.tags.filter { $0.kind != "today" }) { tag in
                            ProjectRow(tasks: self.$tasks, name: tag.name, taskListType: .tag) { task in
                                task.hasTag(tagId: tag.id)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("FirstTask")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        loginButton
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        settingButton
                    }
                }
                .onAppear {
                    reloadView()
                }
                if UIDevice.current.userInterfaceIdiom != .pad && self.showingFabButton {
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
                        _ = Task.create(title: self.$newTaskTitle.wrappedValue, tasks: self.tasks)
                    }
                }
            }
            .onChange(of: sessionState.isSignedIn) {
                reloadView()
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
            reloadView()
        }) {
            SettingMenuView()
        }
    }

    private var loginButton: some View {
        Group {
            if !sessionState.isSignedIn {
                Button(action: {
                    self.showingFirebaseUIView.toggle()
                }) {
                    Image(systemName: "person")
                        .frame(width: 40, height: 40)
                        .imageScale(.large)
                        .clipShape(Circle())
                }.sheet(isPresented: $showingFirebaseUIView) {
                    FirebaseUIView()
                }
            } else {
                Button(action: {
                    self.showingSignOutConfirm = true
                }) {
                    Image(systemName: "person.badge.minus")
                        .frame(width: 40, height: 40)
                        .imageScale(.large)
                        .clipShape(Circle())
                }
                .alert(isPresented: $showingSignOutConfirm) {
                    Alert(
                        title: Text("Sign Out"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            try? self.sessionState.signOut()
                            self.reloadView()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }

    private var todayTagId: String {
        self.appSettings.tags.first { $0.kind == "today" }?.id ?? ""
    }

    private func reloadView() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.appSettings.tags = []
            self.projects = []
            self.tasks = []
            self.showingFabButton = false
            return
        }

        let user = User(id: uid)
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
        self.showingFabButton = true
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
