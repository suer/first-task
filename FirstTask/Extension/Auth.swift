import Firebase
import FirebaseAuth

extension Auth {
    static func safeAuth() -> Auth? {
        if FirebaseApp.isDefaultAppConfigured() {
            return auth()
        }
        return nil
    }
}
