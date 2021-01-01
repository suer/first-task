import Foundation
import CoreData

extension Task {

    var allTags: [Tag] {
//        (self.tags as? Set<Tag> ?? [])
//            .sorted { ($0.name ?? "") <= ($1.name ?? "") }
        []
    }

    static func maxDisplayOrder(context: NSManagedObjectContext) -> Int64 {
//        let context = context
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
//
//        let expressionDescription = NSExpressionDescription()
//        expressionDescription.name = "maxDisplayOrder"
//        expressionDescription.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "displayOrder")])
//        expressionDescription.expressionResultType = NSAttributeType.integer64AttributeType
//
//        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
//        fetchRequest.propertiesToFetch = [expressionDescription]
//
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let max = (results.first as AnyObject).value(forKey: "maxDisplayOrder") as? Int64 {
//                return max
//            } else {
//                return 0
//            }
//        } catch {
//            return 0
//        }
        return 0
    }

    static func countTodayTasks(context: NSManagedObjectContext) -> Int {
//        let request = NSFetchRequest<NSFetchRequestResult>()
//        request.entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
//        request.predicate = NSPredicate(format: "completedAt == nil AND ANY tags.kind = 'today'")
//        do {
//            return try context.count(for: request)
//        } catch {
//            return 0
//        }
        return 0
    }

    static func reorder(context: NSManagedObjectContext, tasks: [Task], source: IndexSet, destination: Int) {
//        var reordered = tasks
//        reordered.move(fromOffsets: source, toOffset: destination)
//
//        for index in stride(from: reordered.count - 1, through: 0, by: -1) {
//            reordered[index].displayOrder = Int64(index)
//        }
//
//        do {
//            try context.save()
//        } catch {
//            // do nothing
//        }
    }

}
