import SwiftUI

struct ProjectAddView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State var project: Project = Project()

    var body: some View {
        NavigationView {
            ProjectFormView(project: project)
            .navigationBarTitle("New Project")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
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
            .environment(\.managedObjectContext, CoreDataSupport.context)
    }
}
