import Foundation
import CoreData

extension Task: Identifiable {
    static func list() -> [Task] {
        // 全県読み出しでなく、SwiftUI + CoreData で見える部分だけ読み出す方法を調べる
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        do {
            return try CoreDataSupport.context.fetch(request) as? [Task] ?? []
        }
        catch {
            return []
        }
    }

    static func make(id: UUID, title: String, completed: Bool = false) -> Task {
        let task = Task(context: CoreDataSupport.context)
        task.id = id
        task.title = title
        task.completed = completed
        return task
    }

    static func create(title: String) -> Task? {
        let task = Task(context: CoreDataSupport.context)
        task.id = UUID()
        task.title = title
        task.completed = false
        let now = Date()
        task.createdAt = now
        task.updatedAt = now
        do {
            try CoreDataSupport.context.save()
            return task
        } catch {
            return nil
        }
    }

    static func destroy(task: Task) {
        do {
            CoreDataSupport.context.delete(task)
            try CoreDataSupport.context.save()
        } catch {
            // do nothing
        }
    }
}
