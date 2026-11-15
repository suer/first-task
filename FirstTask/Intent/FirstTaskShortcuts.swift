import AppIntents

struct FirstTaskShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task to \(.applicationName)",
                "Add a task in \(.applicationName)",
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )
    }
}
