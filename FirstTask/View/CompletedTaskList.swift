import FirebaseAuth
import SwiftUI

struct CompletedTaskList: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var tasks: [Task] = []
    @State var isLoadingTasks = true

    var body: some View {
        Group {
            if self.isLoadingTasks {
                ProgressView()
            } else if self.tasks.isEmpty {
                ContentUnavailableView {
                    Label(.noCompletedTasks, systemImage: "checkmark.circle")
                } description: {
                    Text(.tasksYouCompleteWillAppearHere)
                }
            } else {
                List {
                    ForEach(self.tasks) { task in
                        TaskRow(task: task)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                task.toggleDone()
                            }
                    }
                    .onDelete(perform: removeRow)
                }
            }
        }
        .navigationTitle(.completedTasks)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")
            user
                .collection(path: .completedTasks)
                .addSnapshotListener { querySnapshot, _ in
                    guard let documents = querySnapshot?.documents else { return }

                    self.tasks = documents.map { queryDocumentSnapshot -> Task? in
                        return try? Task(snapshot: queryDocumentSnapshot)
                    }.compactMap { $0 }
                        .sorted { ($0.completedAt?.wrappedValue ?? .distantPast) > ($1.completedAt?.wrappedValue ?? .distantPast) }
                    self.isLoadingTasks = false
                }
        }
    }

    func removeRow(offsets: IndexSet) {
        for i in offsets {
            Task.destroy(task: self.tasks[i])
        }
    }
}

struct CompletedTaskList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CompletedTaskList()
                .environmentObject(AppSettings())
        }
    }
}
