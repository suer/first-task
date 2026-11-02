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

    @Test
    func linkedMemoLinksOnlyURLs() throws {
        let memo = "see https://example.com/a?b=1 and more"
        let attributed = TaskRow.linkedMemo(memo)
        let links = attributed.runs.compactMap { run in
            run.link.map { (String(attributed[run.range].characters), $0) }
        }
        #expect(links.count == 1)
        #expect(links.first?.0 == "https://example.com/a?b=1")
        #expect(links.first?.1 == URL(string: "https://example.com/a?b=1"))
    }

    @Test
    func linkedMemoWithoutURLHasNoLinks() {
        let attributed = TaskRow.linkedMemo("2 bottles of milk")
        #expect(attributed.runs.allSatisfy { $0.link == nil })
        #expect(String(attributed.characters) == "2 bottles of milk")
    }
}
