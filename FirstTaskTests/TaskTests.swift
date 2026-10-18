import FirebaseFirestore
import Foundation
import Testing

@testable import FirstTask

struct TaskTests {

    @Test
    func editableContentIsEqualWhenNothingChanged() {
        let task = Task.make(title: "milk")
        #expect(task.editableContent == task.editableContent)
    }

    @Test
    func editableContentChangesWhenEdited() {
        let task = Task.make(title: "milk")
        let original = task.editableContent

        task.title = "bread"
        #expect(task.editableContent != original)

        task.title = "milk"
        task.memo = "2 bottles"
        #expect(task.editableContent != original)

        task.memo = ""
        task.useDueDate = true
        #expect(task.editableContent != original)
    }

    @Test
    func editableContentIgnoresTagsAndProject() {
        let task = Task.make(title: "milk")
        let original = task.editableContent

        task.tagIds = ["tag"]
        task.projectId = "project"
        #expect(task.editableContent == original)
    }
}
