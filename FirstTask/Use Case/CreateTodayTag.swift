import CoreData

class CreateTodayTag {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func call() {
        // XXX: use kind
        if Tag.findByName(context: context, name: "Today") == nil {
            _ = Tag.create(context: context, name: "Today")
        }
    }
}
