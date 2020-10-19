import SwiftUI

struct ProjectFormView: View {
    @ObservedObject var project: Project

    var body: some View {
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
    }
}

struct ProjectFormView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectFormView(project: Project())
    }
}
