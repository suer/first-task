import Foundation
import CoreData

extension Project {

    static func make(context: NSManagedObjectContext) -> Project {
        let project = Project(context: context)
        project.id = UUID()
        project.createdAt = Date()
        return project
    }

    public var wrappedTitle: String {
        get { title ?? "" }
        set { title = newValue }
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

    func save(context: NSManagedObjectContext) {
        do {
            self.updatedAt = Date()
            try context.save()
        } catch {
            // do nothing
        }
    }

    static func destroy(context: NSManagedObjectContext, project: Project) {
        do {
            context.delete(project)
            try context.save()
        } catch {
            // do nothing
        }
    }
}
