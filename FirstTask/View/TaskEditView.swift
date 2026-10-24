import SwiftUI

struct TaskEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var task: Task
    @State private var original: Task.EditableContent
    @State private var showingCloseConfirmation = false

    init(task: Task) {
        self.task = task
        _original = State(initialValue: task.editableContent)
    }

    var body: some View {
        NavigationStack {
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
                            .accessibilityLabel(Text(.startDate))
                    }
                }
                Section(header: Text(.dueDate)) {
                    Toggle(.setDueDate, isOn: $task.useDueDate)
                    if $task.useDueDate.wrappedValue {
                        DatePicker("", selection: $task.wrappedDueDate, displayedComponents: .date)
                            .accessibilityLabel(Text(.dueDate))
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            if self.task.editableContent == self.original {
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                self.showingCloseConfirmation = true
                            }
                        }) {
                            Image(systemName: "xmark")
                                .frame(width: 40, height: 40)
                                .imageScale(.large)
                                .foregroundColor(.secondary)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel(Text(.close))
                        .confirmationDialog(
                            "",
                            isPresented: self.$showingCloseConfirmation,
                            titleVisibility: .hidden
                        ) {
                            Button(.saveChanges) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            Button(.discardChanges, role: .destructive) {
                                self.discardChanges()
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "checkmark")
                                .frame(width: 40, height: 40)
                                .imageScale(.large)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityLabel(Text(.save))
                    }
                }
        }.onDisappear {
            if task.editableContent != original {
                task.save()
            }
        }
    }

    private func discardChanges() {
        task.title = original.title
        task.memo = original.memo
        task.startDate = original.startDate
        task.dueDate = original.dueDate
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        let task = Task.make(title: "ミルクを買う")
        task.memo = "住まいは田舎がいい、森と日溜まりでひと寝入り、飛ぶ鳥、稲と日照り、まだ独りもいいが、家内はいます"
        return TaskEditView(task: task)
    }
}
