import SwiftUI

struct ProjectEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var project: Project = Project()

    var body: some View {
        NavigationView {
            ProjectFormView(project: project)
            .navigationBarTitle("Edit Project")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }

    private var saveButton: some View {
        Button(action: {
            self.project.save()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
        }
    }

    private var cancelButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
        }
    }
}

struct ProjectEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectEditView()
    }
}
