import SwiftUI

struct TaskEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var task: Task

    var body: some View {
        NavigationView {
            Form {
                TextField(String(localized: .inputTitle), text: $task.title)
                Section(header: Text(.memo)) {
                    TextField(.memo, text: $task.memo, axis: .vertical)
                        .lineLimit(1...5)
                }
                Section(header: Text(.startDate)) {
                    Toggle(.setStartDate, isOn: $task.useStartDate)
                    if $task.useStartDate.wrappedValue {
                        DatePicker("", selection: $task.wrappedStartDate, displayedComponents: .date)
                    }
                }
                Section(header: Text(.dueDate)) {
                    Toggle(.setDueDate, isOn: $task.useDueDate)
                    if $task.useDueDate.wrappedValue {
                        DatePicker("", selection: $task.wrappedDueDate, displayedComponents: .date)
                    }
                }

                Section(header: Text(.tags)) {
                    List {
                        NavigationLink(destination: TagList(task: self.task)) {
                            Group {
                                if task.allTags(tags: appSettings.tags).count > 0 {
                                    ForEach(task.allTags(tags: appSettings.tags)) { tag in
                                        TagBubble(tag: tag)
                                    }
                                    Spacer()
                                } else {
                                    Text(.tags)
                                }
                            }
                        }
                    }
                }
            }.navigationTitle(.editTask)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .frame(width: 40, height: 40)
                                .imageScale(.large)
                                .foregroundColor(Color(UIColor(named: "Accent")!))
                                .clipShape(Circle())
                        }
                    }
                }
        }.onDisappear {
            task.save()
        }
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        let task = Task.make(title: "ミルクを買う")
        task.memo = "住まいは田舎がいい、森と日溜まりでひと寝入り、飛ぶ鳥、稲と日照り、まだ独りもいいが、家内はいます"
        return TaskEditView(task: task)
    }
}
