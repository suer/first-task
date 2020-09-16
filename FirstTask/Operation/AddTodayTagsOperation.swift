import Foundation

class AddTodayTagsOperaiton: Operation {
    override func start() {
        AddTodayTag(context: CoreDataSupport.context).call()
    }
}
