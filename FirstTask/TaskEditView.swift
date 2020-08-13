import SwiftUI

struct TaskEditView: View {
    @ObservedObject var task: Task
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                IMETextField(title: "Input title", text: $task.wrappedTitle)
                Section(header: Text("Memo")) {
                    IMETextField(title: "", text: $task.wrappedMemo)
                }
            }.navigationBarTitle("Edit Task")
                .navigationBarItems(trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 40, height: 40)
                        .imageScale(.large)
                        .foregroundColor(Color(UIColor(named: "Accent")!))
                        .clipShape(Circle())
                })
        }
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        let task = Task.make(id: UUID(), title: "ミルクを買う")
        task.memo = "住まいは田舎がいい、森と日溜まりでひと寝入り、飛ぶ鳥、稲と日照り、まだ独りもいいが、家内はいます"
        return TaskEditView(task: task)
    }
}
