import SwiftUI
import MobileCoreServices

struct TaskList: View {
    @State var tasks: [Task]
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
                    }.padding()
                }.padding()

                BottomSheetModal(isShown: $showModal, height: $keyboardHeight) {
                    HStack {
                        FocusableTextField(text: self.$newTaskTitle, isFirstResponder: true) { text in
                        }
                        .frame(width: 300, height: 50)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: {
                            if let task = Task.create(title: self.$newTaskTitle.wrappedValue) {
                                self.tasks.append(task)
                            }
                            self.$newTaskTitle.wrappedValue = ""
                            self.showModal = false
                            UIApplication.shared.closeKeyboard()
                        }) {
                            Image(systemName: "paperplane")
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
        tasks.remove(atOffsets: offsets)
    }
}

struct TaskList_Previews: PreviewProvider {
    static var previews: some View {
        TaskList(
            tasks: [
                Task.make(id: UUID(), title: "ミルクを買う"),
                Task.make(id: UUID(), title: "メールを返す")
        ])
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
