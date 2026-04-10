import SwiftUI

struct ProjectFormView: View {
    @ObservedObject var project: Project

    var body: some View {
        Form {
            TextField(String(localized: .inputTitle), text: $project.title)
            Section(header: Text(.startDate)) {
                Toggle(.setStartDate, isOn: $project.useStartDate)
                if $project.useStartDate.wrappedValue {
                    DatePicker("", selection: $project.wrappedStartDate, displayedComponents: .date)
                }
            }
            Section(header: Text(.dueDate)) {
                Toggle(.setDueDate, isOn: $project.useDueDate)
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
