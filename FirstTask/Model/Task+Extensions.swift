import Foundation
import CoreData

extension Task: Identifiable {

    var allTags: [Tag] {
        (self.tags as? Set<Tag> ?? [])
            .sorted { ($0.name ?? "") <= ($1.name ?? "") }
    }

    static func make(context: NSManagedObjectContext, id: UUID, title: String, completedAt: Date = Date()) -> Task {
        let task = Task(context: context)
        task.id = id
        task.title = title
        task.completedAt = completedAt
        return task
    }

    static func create(context: NSManagedObjectContext, title: String) -> Task? {
        let task = Task(context: context)
        task.id = UUID()
        task.title = title
        let now = Date()
        task.createdAt = now
        task.updatedAt = now
        task.displayOrder = maxDisplayOrder(context: context) + 1
        do {
            try context.save()
            return task
        } catch {
            return nil
        }
    }

    static func destroy(context: NSManagedObjectContext, task: Task) {
        do {
            context.delete(task)
            try context.save()
        } catch {
            // do nothing
        }
    }

    static func maxDisplayOrder(context: NSManagedObjectContext) -> Int64 {
        let context = context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Task", in: context)

        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxDisplayOrder"
        expressionDescription.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "displayOrder")])
        expressionDescription.expressionResultType = NSAttributeType.integer64AttributeType

        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.propertiesToFetch = [expressionDescription]

        do {
            let results = try context.fetch(fetchRequest)
            if let max = (results.first as AnyObject).value(forKey: "maxDisplayOrder") as? Int64 {
                return max
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }

    static func countTodayTasks(context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        request.predicate = NSPredicate(format: "completedAt == nil AND ANY tags.kind = 'today'")
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }

    public var wrappedTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    public var wrappedMemo: String {
        get { memo ?? "" }
        set { memo = newValue }
    }

    public var wrappedStartDate: Date {
        get { startDate ?? .distantPast }
        set { startDate = newValue }
    }

    public var useStartDate: Bool {
        get { startDate != nil }
        set {
            if newValue {
                startDate = Date()
            } else {
                startDate = nil
            }
        }
    }

    public var wrappedDueDate: Date {
        get { dueDate ?? .distantPast }
        set { dueDate = newValue }
    }

    public var useDueDate: Bool {
        get { dueDate != nil }
        set {
            if newValue {
                dueDate = Date()
            } else {
                dueDate = nil
            }
        }
    }

    func hasTag(tagName: String) -> Bool {
        if tagName.isEmpty {
            return true
        }
        return allTags.contains(where: { $0.name == tagName })
    }

    func toggleDone(context: NSManagedObjectContext) {
        self.completedAt = self.completedAt == nil ? Date() : nil
        self.save(context: context)
    }

    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            // do nothing
        }
    }

    static func reorder(context: NSManagedObjectContext, tasks: [Task], source: IndexSet, destination: Int) {
        var reordered = tasks
        reordered.move(fromOffsets: source, toOffset: destination)

        for index in stride(from: reordered.count - 1, through: 0, by: -1) {
            reordered[index].displayOrder = Int64(index)
        }

        do {
            try context.save()
        } catch {
            // do nothing
        }
    }

}
