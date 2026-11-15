import AppIntents

struct AddTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Task"
    static let description = IntentDescription("Adds a task to the inbox.")

    @Parameter(title: "Title", requestValueDialog: "What is the task?")
    var taskTitle: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$taskTitle) to the inbox")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let title = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw $taskTitle.needsValueError("What is the task?")
        }
        try await AddInboxTask.call(title: title)
        return .result(dialog: "Added \"\(title)\" to the inbox.")
    }
}
