import Foundation
import CoreData

extension Tag: Identifiable {
    static func create(task: Task, name: String) -> Tag? {
        let tag = Tag(context: CoreDataSupport.context)
        tag.name = name
        tag.addToTasks(task)
        do {
            try CoreDataSupport.context.save()
            return tag
        } catch {
            return nil
        }
    }
}
