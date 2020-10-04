import SwiftUI
import MobileCoreServices

struct TaskList: View {
    @Environment(\.managedObjectContext) var viewContext
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

    var filter: (Task) -> Bool = { _ in true }

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
                    .sheet(isPresented: self.$modalState.showingEditModal, onDismiss: {
                        editingTask.save(context: self.viewContext)
                    }) {
                        TaskEditView(task: editingTask)
                            .environment(\.managedObjectContext, self.viewContext)
                    }
                }
                .onDelete(perform: removeRow)
                .onMove(perform: move)
                .onTapGesture { } // work around to scroll list with onLongPressGesture
                .onLongPressGesture {
                    withAnimation {
                        // XXX: editing with filtered view
                        self.editing = self.filteringTagName.isEmpty
                    }
                }

            }
            .environment(\.editMode, self.editing ? .constant(.active) : .constant(.inactive))
            .navigationBarTitle(navigationBarTitle)
            .navigationBarItems(
                leading: settingButton,
                trailing: searchButton
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

    private var settingButton: some View {
        Button(action: {
            self.modalState.showingEditModal = false
            self.modalState.showingSearchModal = false
            self.modalState.showingSettingMenuModal = true
        }) {
            Image(systemName: "gear")
                .frame(width: 40, height: 40)
                .imageScale(.large)
                .clipShape(Circle())
        }.sheet(isPresented: self.$modalState.showingSettingMenuModal, onDismiss: {
            self.modalState.showingSettingMenuModal = false
        }) {
            SettingMenuView().environment(\.managedObjectContext, self.viewContext)
        }
    }

    private var searchButton: some View {
        Button(action: {
            self.modalState.showingEditModal = false
            self.modalState.showingSettingMenuModal = false
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
