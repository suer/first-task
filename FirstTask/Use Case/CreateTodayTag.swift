import CoreData

class CreateTodayTag {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func call() {
        if Tag.findByKind(context: context, kind: "today") == nil {
            _ = Tag.create(context: context, name: "Today", kind: "today")
        }
    }
}
