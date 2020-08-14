import CoreData
import UIKit

class CoreDataSupport {
    static var context: NSManagedObjectContext {
        // swiftlint:disable:next force_cast
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}
