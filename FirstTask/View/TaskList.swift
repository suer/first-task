import SwiftUI

struct TaskList: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var appSettings: AppSettings

    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.displayOrder, ascending: true)],
        predicate: NSPredicate(format: "completedAt == nil")
    ) var tasks: FetchedResults<Task>

    @ObservedObject var modalState = ModalState()
    @State var editing: Bool = false
    @State var newTaskTitle: String = ""
    @State var filteringTagName = ""
    @State var navigationBarTitle = "Tasks"
    @State var editingTask: Task?
    @State var showingProjectActionSheet = false
    @State var showingProjectEditModal = false
    @State var showingTaskActionSheet = false
    @State var showingProjectMoveModal = false

    var filter: (Task) -> Bool = { _ in true }
    var project: Project?

    var filteredTasks: [Task] {
        tasks.filter { filter($0) && $0.hasTag(tagName: self.filteringTagName) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(self.filteredTasks) { task in
                    taskRow(task: task)
                }
                .onDelete(perform: removeRow)
                .onMove(perform: move)
                .onTapGesture { } // work around to scroll list with onLongPressGesture
            }
            .environment(\.editMode, self.editing ? .constant(.active) : .constant(.inactive))
            .navigationBarTitle(navigationBarTitle)
            .navigationBarItems(
                trailing: HStack {
                    searchButton
                    if self.project != nil {
                        projectButton
                    }
                }
            )
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
                let task = Task.create(context: self.viewContext, title: self.$newTaskTitle.wrappedValue)
                if let tag = Tag.findByName(context: self.viewContext, name: self.filteringTagName) {
                    task?.addToTags(tag)
                }
                task?.project = self.project
            }

            BottomSheetModal(isShown: self.$showingProjectMoveModal) {
                ProjectSelectView(project: self.project) { project in
                    self.editingTask.map({ task in task.project = project })
                }
                .padding()
                .frame(height: 360)
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        offsets.forEach { i in
            Task.destroy(context: self.viewContext, task: self.filteredTasks[i])
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        Task.reorder(context: self.viewContext, tasks: self.filteredTasks.map { $0 }, source: source, destination: destination)

        withAnimation {
            self.editing = false
        }
    }

    func taskRow(task: Task) -> some View {
        TaskRow(task: task)
            .contentShape(Rectangle()) // can tap Spacer
            .onTapGesture {
                self.editingTask = task
            }
            .onLongPressGesture {
                guard !self.editing else { return }
                self.editingTask = task
                self.showingTaskActionSheet.toggle()
            }
            .sheet(item: self.$editingTask, onDismiss: {
                self.editingTask.map({ task in task.save(context: self.viewContext) })
            }) { task in
                TaskEditView(task: task)
                    .environment(\.managedObjectContext, self.viewContext)
            }
            .actionSheet(isPresented: self.$showingTaskActionSheet) {
                ActionSheet(title: Text(self.editingTask!.title ?? ""),
                            buttons: [
                                .default(Text("Reorder")) {
                                    withAnimation {
                                        // XXX: editing with filtered view
                                        self.editing = self.filteringTagName.isEmpty
                                    }
                                },
                                .default(Text("Move")) {
                                    self.showingProjectMoveModal = true
                                },
                                .destructive(Text("Delete")) {
                                    Task.destroy(context: self.viewContext, task: self.editingTask!)
                                },
                                .cancel(Text("Cancel"))
                            ])
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
        }.sheet(isPresented: self.$modalState.showingSearchModal, onDismiss: {
            self.modalState.showingSearchModal = false
        }) {
            SearchView(filteringTagName: self.$filteringTagName)
                .environment(\.managedObjectContext, self.viewContext)
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
        }.actionSheet(isPresented: self.$showingProjectActionSheet) {
            ActionSheet(title: Text(self.project!.title ?? ""),
                buttons: [
                    .default(Text("Edit")) {
                        self.showingProjectEditModal = true
                    },
                    .default(Text("Complete")) {
                        self.presentation.wrappedValue.dismiss()
                        self.project!.toggleDone(context: self.viewContext)
                    },
                    .destructive(Text("Delete")) {
                        self.presentation.wrappedValue.dismiss()
                        Project.destroy(context: self.viewContext, project: self.project!)
                    },
                    .cancel(Text("Cancel"))
            ])
        }.sheet(isPresented: self.$showingProjectEditModal) {
            ProjectEditView(project: self.project!)
                .environment(\.managedObjectContext, self.viewContext)
                .onDisappear {
                    self.navigationBarTitle = self.project!.wrappedTitle
                }
        }
    }
}

struct TaskList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskList()
                .environment(\.managedObjectContext, CoreDataSupport.context)
                .environmentObject(AppSettings())
        }
    }
}
