import SwiftUI

struct ProjectAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var project: Project = Project()

    var body: some View {
        NavigationView {
            ProjectFormView(project: project)
                .navigationTitle("New Project")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelButton
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        saveButton
                    }
                }
        }
    }

    private var saveButton: some View {
        Button(action: {
            _ = Project.create(project)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
        }
    }

    private var cancelButton: some View {
        Button(action: {
            Project.destroy(project: project)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
        }
    }
}

struct ProjectAddView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectAddView(project: Project())
    }
}
