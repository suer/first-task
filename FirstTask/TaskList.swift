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
    @State var newTaskTitle: String = ""
    @State var editing: Bool = false

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
                .navigationBarTitle("Tasks")
                .environment(\.editMode, self.editing ? .constant(.active) : .constant(.inactive))
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FabButton {
                            self.appSettings.showAddTaskModal = true
                        }
                    }.padding(10)
                }.padding(10)

                BottomSheetModal(isShown: $appSettings.showAddTaskModal) {
                    GeometryReader { geometry in
                        HStack {
                            FocusableTextField(text: self.$newTaskTitle, isFirstResponder: true) { _ in }
                                .frame(width: geometry.size.width - 40, height: 50)
                                .keyboardType(.default)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: {
                                _ = Task.create(context: self.viewContext, title: self.$newTaskTitle.wrappedValue)
                                self.$newTaskTitle.wrappedValue = ""
                                self.appSettings.showAddTaskModal = false
                                UIApplication.shared.closeKeyboard()
                            }) {
                                Image(systemName: "arrow.up")
                                    .frame(width: 40, height: 40)
                                    .imageScale(.large)
                                    .background(Color(UIColor(named: "Accent")!))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    .frame(height: 80)
                }
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
