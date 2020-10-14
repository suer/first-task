import SwiftUI

struct ProjectSelectView: View {
    @Environment(\.presentationMode) var presentation
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)]
    ) var projects: FetchedResults<Project>
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
            }.onTapGesture {
                self.action(nil)
                self.presentation.wrappedValue.dismiss()
            }
            ForEach(self.projects) { project in
                HStack {
                    Image(systemName: self.project == project ? "checkmark.circle.fill" : "circle")
                    Text(project.title ?? "")
                }.onTapGesture {
                    self.action(project)
                    self.presentation.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ProjectSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataSupport.context
        let project = Project(context: context)
        project.title = "ピクニックの準備をする"
        return ProjectSelectView(project: project) { _ in }
    }
}
