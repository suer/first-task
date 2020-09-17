import CoreData

class AddTodayTag {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func call() {
        let today = Date()

        if let todayTag = Tag.findByKind(context: context, kind: "today") {
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
            request.predicate = NSPredicate(format: "completedAt == nil AND startDate >= %@ AND startDate <= %@",
                                            today.startOfDay as NSDate, today.endOfDay as NSDate)
            do {
                let tasks = try context.fetch(request)
                tasks.forEach {
                    if let task = $0 as? Task {
                        if !task.allTags.contains(todayTag) {
                            task.addToTags(todayTag)
                        }
                    }
                }
            } catch {
                // do nothing
            }
        }
    }
}
