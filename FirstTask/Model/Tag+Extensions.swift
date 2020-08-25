import Foundation
import CoreData

extension Tag: Identifiable {
    static func create(context: NSManagedObjectContext, name: String, task: Task? = nil) -> Tag? {
        let tag = Tag(context: context)
        tag.name = name
        if let task = task {
            tag.addToTasks(task)
        }
        do {
            try context.save()
            return tag
        } catch {
            return nil
        }
    }

    static func destroy(context: NSManagedObjectContext, tag: Tag) {
        do {
            context.delete(tag)
            try context.save()
        } catch {
            // do nothing
        }
    }
}
