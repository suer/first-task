import Foundation

class AddTodayTagsOperaiton: Operation {
    override func start() {
        AddTodayTag().call()
    }
}
