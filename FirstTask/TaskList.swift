import SwiftUI
import MobileCoreServices

struct TaskList: View {
    @FetchRequest(
       entity: Task.entity(),
       sortDescriptors: [NSSortDescriptor(keyPath: \Task.displayOrder, ascending: true)],
       predicate: NSPredicate(format: "completedAt == nil")
    ) var tasks: FetchedResults<Task>

    @State var showModal: Bool = false
    @State var newTaskTitle: String = ""
    @State var keyboardHeight: CGFloat = CGFloat(340)
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(tasks) { task in
                        TaskRow(task: task)
                    }
                    .onDelete(perform: removeRow)
                }
                .navigationBarTitle("Tasks")
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FabButton {
                            self.showModal = true
                            // TDOO: キーボードの高さを取得して keyboardHeight を設定する
                        }
                    }.padding(10)
                }.padding(10)
                
                BottomSheetModal(isShown: $showModal, height: $keyboardHeight) {
                    HStack {
                        FocusableTextField(text: self.$newTaskTitle, isFirstResponder: true) { text in
                        }
                        .frame(width: 300, height: 50)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            _ = Task.create(title: self.$newTaskTitle.wrappedValue)
                            self.$newTaskTitle.wrappedValue = ""
                            self.showModal = false
                            UIApplication.shared.closeKeyboard()
                        }) {
                            Image(systemName: "arrow.up")
                                .frame(width: 40, height: 40)
                                .imageScale(.large)
                                .background(Color(UIColor(red: 33/255, green: 125/255, blue: 251/255, alpha: 1.0)))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    func removeRow(offsets: IndexSet) {
        offsets.forEach { i in
            Task.destroy(task: tasks[i])
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
