import SwiftUI
import MobileCoreServices

struct TaskList: View {
    @State var tasks: [Task]
    @State var showModal: Bool = false
    @State var newTaskTitle: String = ""
    @State var keyboardHeight: CGFloat = CGFloat(340)

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(tasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: removeRow)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FavButton {
                        self.showModal = true
                        // TDOO: キーボードの高さを取得して keyboardHeight を設定する
                    }
                }.padding()
            }.padding()

            BottomSheetModal(isShown: $showModal, height: $keyboardHeight) {
                FocusableTextField(text: self.$newTaskTitle, isFirstResponder: true)
                    .frame(width: 300, height: 50)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
        }
    }

    func removeRow(offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct TaskList_Previews: PreviewProvider {
    static var previews: some View {
        TaskList(
            tasks: [
                Task(id: 1, title: "ミルクを買う"),
                Task(id: 2, title: "メールを返す")
        ])
    }
}
