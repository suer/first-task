import SwiftUI
import MobileCoreServices

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
    @State var editingTask: Task = Task()
    @State var showingProjectActionSheet = false
    @State var showingProjectEditModal = false
    @State var showingTaskActionSheet = false

    var filter: (Task) -> Bool = { _ in true }
    var project: Project?

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(tasks.filter { filter($0) && $0.hasTag(tagName: self.filteringTagName) }) { task in
                    TaskRow(task: task)
                    .contentShape(Rectangle()) // can tap Spacer
                    .onTapGesture {
                        editingTask = task
                        self.modalState.showingEditModal.toggle()
                    }
                    .onLongPressGesture {
                        if !self.editing {
                            editingTask = task
                            self.showingTaskActionSheet.toggle()
                        }
                    }
                    .sheet(isPresented: self.$modalState.showingEditModal, onDismiss: {
                        editingTask.save(context: self.viewContext)
                    }) {
                        TaskEditView(task: editingTask)
                            .environment(\.managedObjectContext, self.viewContext)
                    }
                    .actionSheet(isPresented: self.$showingTaskActionSheet) {
                        ActionSheet(title: Text(task.title ?? ""),
                                    buttons: [
                                        .default(Text("Reorder")) {
                                            withAnimation {
                                                // XXX: editing with filtered view
                                                self.editing = self.filteringTagName.isEmpty
                                            }
                                        },
                                        .destructive(Text("Delete")) {
                                            Task.destroy(context: self.viewContext, task: self.editingTask)
                                        },
                                        .cancel(Text("Cancel"))
                                    ])
                    }
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
                self.appSettings.showAddTaskModal = false
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        offsets.forEach { i in
            Task.destroy(context: self.viewContext, task: tasks[i])
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        Task.reorder(context: self.viewContext, tasks: tasks.map { $0 }, source: source, destination: destination)

        withAnimation {
            self.editing = false
        }
    }

    private var searchButton: some View {
        Button(action: {
            self.modalState.showingEditModal = false
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

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
