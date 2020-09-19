import Foundation
import CoreData

extension Tag {
    static func create(context: NSManagedObjectContext, name: String, task: Task? = nil, kind: String? = nil) -> Tag? {
        let tag = Tag(context: context)
        tag.name = name
        if let task = task {
            tag.addToTasks(task)
        }
        if let kind = kind {
            tag.kind = kind
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

    static func destroyAll(context: NSManagedObjectContext) {
        do {
            try context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Tag")))
        } catch {
            // do nothing
        }
    }

    static func findByName(context: NSManagedObjectContext, name: String) -> Tag? {
        if name.isEmpty {
            return nil
        }
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: "Tag", in: context)
        request.predicate = NSPredicate(format: "name == %@", name)
        do {
            if let tag = try context.fetch(request).first as? Tag {
                return tag
            }
        } catch {
            // do nothing
        }
        return nil
    }

    static func findByKind(context: NSManagedObjectContext, kind: String) -> Tag? {
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: "Tag", in: context)
        request.predicate = NSPredicate(format: "kind == %@", kind)
        do {
            if let tag = try context.fetch(request).first as? Tag {
                return tag
            }
        } catch {
            // do nothing
        }
        return nil
    }
}
