import Foundation
import CoreData

extension Task: Identifiable {
    
    static func make(id: UUID, title: String, completedAt: Date = Date()) -> Task {
        let task = Task(context: CoreDataSupport.context)
        task.id = id
        task.title = title
        task.completedAt = completedAt
        return task
    }

    static func create(title: String) -> Task? {
        let task = Task(context: CoreDataSupport.context)
        task.id = UUID()
        task.title = title
        let now = Date()
        task.createdAt = now
        task.updatedAt = now
        task.displayOrder = maxDisplayOrder() + 1
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

    static func maxDisplayOrder() -> Int64 {
        let context = CoreDataSupport.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Task", in: context)

        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxDisplayOrder"
        expressionDescription.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "displayOrder")])
        expressionDescription.expressionResultType = NSAttributeType.integer64AttributeType

        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.propertiesToFetch = [expressionDescription]

        do {
            let results = try CoreDataSupport.context.fetch(fetchRequest)
            if let max = (results.first as AnyObject).value(forKey: "maxDisplayOrder") as? Int64 {
                return max
            } else {
                return 0
            }
        } catch {
            return 0
        }

    }
    
    public var wrappedTitle: String {
        get{title ?? ""}
        set{title = newValue}
    }
    
    public var wrappedMemo: String {
        get{memo ?? ""}
        set{memo = newValue}
    }
    
    func toggleDone() {
        self.completedAt = self.completedAt == nil ? Date() : nil
        self.save()
    }
    
    func save() {
        do {
            try CoreDataSupport.context.save()
        } catch {
            // do nothing
        }
    }

    static func reorder(tasks: [Task], source: IndexSet, destination: Int) {
        var reordered = tasks
        reordered.move(fromOffsets: source, toOffset: destination)

        for index in stride(from: reordered.count - 1, through: 0, by: -1) {
            reordered[index].displayOrder = Int64(index)
        }

        do {
            try CoreDataSupport.context.save()
        } catch {
            // do nothing
        }
    }

}
