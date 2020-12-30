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
            self.project.save(context: self.viewContext)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
        }
    }

    private var cancelButton: some View {
        Button(action: {
//            self.viewContext.delete(self.project) // TODO
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
        }
    }
}

struct ProjectAddView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectAddView(project: Project.make(context: CoreDataSupport.context))
            .environment(\.managedObjectContext, CoreDataSupport.context)
    }
}
