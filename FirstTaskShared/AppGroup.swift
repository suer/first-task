import Foundation

enum AppGroup {
    static let identifier = "group.org.codefirst.FirstTaskExtension"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
