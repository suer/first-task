import Foundation
import CoreData

extension Tag: Identifiable {
    static func create(context: NSManagedObjectContext, task: Task, name: String) -> Tag? {
        let tag = Tag(context: context)
        tag.name = name
        tag.addToTasks(task)
        do {
            try context.save()
            return tag
        } catch {
            return nil
        }
    }
}
