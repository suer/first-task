import FirebaseAuth
import SwiftUI

struct TaskList: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var appSettings: AppSettings

    @State var tasks: [Task] = []

    @ObservedObject var modalState = ModalState()
    @State var editing: Bool = false
    @State var newTaskTitle: String = ""
    @State var filteringTagName = ""
    @State var navigationBarTitle = "Tasks"
    @State var editingTaskID: String?
    @State var movingTask: Task?
    @State var showingProjectActionSheet = false
    @State var showingProjectEditModal = false
    @State var showingProjectMoveModal = false

    var filter: (Task) -> Bool = { _ in true }
    var project: Project?
    var taskListType: TaskListType

    var filteredTasks: [Task] {
        tasks.filter { filter($0) && $0.hasTagByName(tags: self.appSettings.tags, name: self.filteringTagName) }
    }

    private var isEditing: Binding<Bool> {
        Binding(
            get: { self.editingTaskID != nil },
            set: { isShowing in
                if !isShowing {
                    self.editingTaskID = nil
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(self.filteredTasks) { task in
                    taskRow(task: task)
                }
                .onDelete(perform: removeRow)
                .onMove(perform: move)
                .onTapGesture {}  // work around to scroll list with onLongPressGesture
            }
            .environment(\.editMode, self.editing ? .constant(.active) : .constant(.inactive))
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        searchButton
                        if self.project != nil {
                            projectButton
                        }
                    }
                }
            }
            .onAppear {
                let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                user
                    .collection(path: .tasks)
                    .whereField("projectId", isEqualTo: project?.documentReference.documentID ?? "")
                    .order(by: "displayOrder")
                    .addSnapshotListener { querySnapshot, _ in
                        guard let documents = querySnapshot?.documents else { return }

                        self.tasks = documents.map { queryDocumentSnapshot -> Task? in
                            return try? Task(snapshot: queryDocumentSnapshot)
                        }.compactMap { $0 }
                    }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FabButton {
                        self.appSettings.showAddTaskModal = true
                    }
                }.padding(10)
            }.padding(10)

            BottomTextFieldSheetModal(isShown: $appSettings.showAddTaskModal, text: self.$newTaskTitle) {
                let tag: Tag? =
                    if self.taskListType == .tag {
                        self.appSettings.tags.first { $0.name == navigationBarTitle }
                    } else if self.taskListType == .today {
                        self.appSettings.tags.first { $0.kind == "today" }
                    } else {
                        nil
                    }

                _ = Task.create(
                    title: self.$newTaskTitle.wrappedValue,
                    projectId: self.project?.id ?? "",
                    tagId: tag?.id ?? "",
                    tasks: self.tasks)
            }

            BottomSheetModal(isShown: self.$showingProjectMoveModal) {
                ProjectSelectView(project: self.project) { project in
                    self.movingTask.map { task in
                        task.projectId = project?.id ?? ""
                        task.save()
                    }
                    self.showingProjectMoveModal = false
                }
                .padding()
                .frame(height: 360)
            }
        }
        .sheet(isPresented: isEditing, onDismiss: {
            if let id = self.editingTaskID, let task = self.tasks.first(where: { $0.id == id }) {
                task.save()
            }
        }) {
            if let id = self.editingTaskID, let task = self.tasks.first(where: { $0.id == id }) {
                TaskEditView(task: task)
            } else {
                ProgressView()
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        for i in offsets {
            Task.destroy(task: self.filteredTasks[i])
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        Task.reorder(tasks: self.filteredTasks.map { $0 }, source: source, destination: destination)

        withAnimation {
            self.editing = false
        }
    }

    func taskRow(task: Task) -> some View {
        TaskRow(task: task)
            .contentShape(Rectangle())  // can tap Spacer
            .onTapGesture {
                self.editingTaskID = task.id
            }
            .contextMenu {
                Button(action: {
                    withAnimation {
                        // XXX: editing with filtered view
                        self.editing = self.filteringTagName.isEmpty
                    }
                }) {
                    Text("Reorder")
                    Image(systemName: "arrow.up.arrow.down")
                }
                Button(action: {
                    self.movingTask = task
                    self.showingProjectMoveModal = true
                }) {
                    Text("Move")
                    Image(systemName: "arrow.turn.up.right")
                }
                Button(action: {
                    Task.destroy(task: task)
                }) {
                    Text("Delete")
                    Image(systemName: "trash")
                }
            }
    }

    private var searchButton: some View {
        Button(action: {
            self.modalState.showingSearchModal = true
        }) {
            Image(systemName: "magnifyingglass")
                .frame(width: 40, height: 40)
                .imageScale(.large)
                .clipShape(Circle())
        }.sheet(
            isPresented: self.$modalState.showingSearchModal,
            onDismiss: {
                self.modalState.showingSearchModal = false
            }
        ) {
            SearchView(filteringTagName: self.$filteringTagName)
                .environmentObject(AppSettings())
        }
    }

    private var projectButton: some View {
        Button(action: {
            self.showingProjectActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .frame(width: 40, height: 40)
                .imageScale(.large)
                .clipShape(Circle())
        }.sheet(isPresented: self.$showingProjectEditModal) {
            ProjectEditView(project: self.project!)
                .onDisappear {
                    self.navigationBarTitle = self.project?.title ?? self.navigationBarTitle
                }
        }.confirmationDialog(
            self.project?.title ?? "Task",
            isPresented: self.$showingProjectActionSheet,
            titleVisibility: .visible
        ) {
            Button("Edit") {
                self.showingProjectEditModal = true
            }
            Button("Complete") {
                self.presentation.wrappedValue.dismiss()
                self.project!.toggleDone()
            }
            Button("Delete", role: .destructive) {
                self.presentation.wrappedValue.dismiss()
                Project.destroy(project: self.project!)
            }
        }
    }

    private var title: String {
        guard let subtitle = self.taskListType.subtitle() else {
            return navigationBarTitle
        }
        return "\(navigationBarTitle) - \(subtitle)"
    }
}

struct TaskList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskList(taskListType: .project)
                .environmentObject(AppSettings())
        }
    }
}
