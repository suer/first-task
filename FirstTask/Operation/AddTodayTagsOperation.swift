import Foundation

class AddTodayTagsOperaiton: Operation, @unchecked Sendable {
    override func start() {
        AddTodayTag().call()
    }
}
