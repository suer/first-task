import SwiftUI
import MobileCoreServices

struct TaskList: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
       entity: Task.entity(),
       sortDescriptors: [NSSortDescriptor(keyPath: \Task.displayOrder, ascending: true)],
       predicate: NSPredicate(format: "completedAt == nil")
    ) var tasks: FetchedResults<Task>

    @State var showingEditModal: Bool = false
    @State var showingSettingMenuModal: Bool = false
    @State var editing: Bool = false
    @State var newTaskTitle: String = ""

    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(tasks) { task in
                        Button(action: { self.showingEditModal.toggle() }) {
                            TaskRow(task: task)
                        }
                        .sheet(isPresented: self.$showingEditModal, onDismiss: {
                            task.save(context: self.viewContext)
                        }) {
                            TaskEditView(task: task)
                                .environment(\.managedObjectContext, self.viewContext)
                        }
                    }
                    .onDelete(perform: removeRow)
                    .onMove(perform: move)
                    .onTapGesture { } // work around to scroll list with onLongPressGesture
                    .onLongPressGesture {
                        withAnimation {
                            self.editing = true
                        }
                    }
                }
                .environment(\.editMode, self.editing ? .constant(.active) : .constant(.inactive))
                .navigationBarTitle("Tasks")
                .navigationBarItems(trailing: Button(action: {
                    self.showingEditModal = false
                    self.showingSettingMenuModal = true
                }
                ) {
                    Image(systemName: "gear")
                        .frame(width: 40, height: 40)
                        .imageScale(.large)
                        .clipShape(Circle())
                }.sheet(isPresented: self.$showingSettingMenuModal, onDismiss: {
                    self.showingSettingMenuModal = false
                }) {
                    SettingMenuView().environment(\.managedObjectContext, self.viewContext)
                })
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
                    _ = Task.create(context: self.viewContext, title: self.$newTaskTitle.wrappedValue)
                    self.appSettings.showAddTaskModal = false
                }
            }
        }.onAppear(perform: {
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.badge]) { _, _ in }
        })
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
}

struct TaskList_Previews: PreviewProvider {
    @FetchRequest(
       entity: Task.entity(),
       sortDescriptors: [NSSortDescriptor(keyPath: \Task.displayOrder, ascending: true)],
       predicate: NSPredicate(format: "completed == %@", NSNumber(value: false))
    ) var tasks: FetchedResults<Task>

    static var previews: some View {
        TaskList()
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
