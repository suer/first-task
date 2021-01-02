import SwiftUI
import FirebaseAuth

struct ProjectSelectView: View {
    @Environment(\.presentationMode) var presentation
    @State var projects: [Project] = []
    var project: Project?
    var action: (Project?) -> Void

    init(project: Project?, action: @escaping (Project?) -> Void) {
        self.project = project
        self.action = action
    }

    var body: some View {
        List {
            HStack {
                Image(systemName: self.project == nil ? "checkmark.circle.fill" : "circle")
                Text("No project")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.action(nil)
                self.presentation.wrappedValue.dismiss()
            }
            ForEach(self.projects) { project in
                HStack {
                    Image(systemName: self.project == project ? "checkmark.circle.fill" : "circle")
                    Text(project[\.title])
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.action(project)
                    self.presentation.wrappedValue.dismiss()
                }
            }
        }.onAppear {
            User(id: Auth.auth().currentUser?.uid ?? "NotFound")
                .collection(path: .projects)
                .order(by: "title")
                .addSnapshotListener { querySnapshot, _ in
                    guard let documents = querySnapshot?.documents else { return }

                    self.projects = documents.map { queryDocumentSnapshot -> Project? in
                        return try? Project(snapshot: queryDocumentSnapshot)
                    }.compactMap { $0 }
                }
        }
    }
}

struct ProjectSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project()
        project[\.title] = "ピクニックの準備をする"
        return ProjectSelectView(project: project) { _ in }
    }
}
