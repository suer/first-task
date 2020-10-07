import SwiftUI

struct ProjectAddView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State var project: Project = Project()

    var body: some View {
        NavigationView {
            Form {
                IMETextField(title: "Input title", text: $project.wrappedTitle)
                Section(header: Text("Start Date")) {
                     Toggle("Set Start Date", isOn: $project.useStartDate)
                     if $project.useStartDate.wrappedValue {
                         DatePicker("", selection: $project.wrappedStartDate, displayedComponents: .date)
                     }
                }
                Section(header: Text("Due Date")) {
                    Toggle("Set Due Date", isOn: $project.useDueDate)
                    if $project.useDueDate.wrappedValue {
                        DatePicker("", selection: $project.wrappedDueDate, displayedComponents: .date)
                    }
                }
            }
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
            self.viewContext.delete(self.project)
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
