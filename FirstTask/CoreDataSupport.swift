import CoreData
import UIKit

class CoreDataSupport {
    static var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}
