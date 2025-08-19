import FirebaseAuth
import FirebaseFirestore

class SessionState: ObservableObject {
    @Published var isSignedIn: Bool = false
    private var handle: AuthStateDidChangeListenerHandle!

    init() {
        handle = Auth.auth().addStateDidChangeListener { (_, user) in
            if user != nil {
                print("Sign-in")
                if let user = user {
                    let u = User(id: user.uid)
                    u.email = user.email ?? ""
                    u.photoURL = user.photoURL?.absoluteString ?? ""
                    do {
                        try u.documentReference.setData(from: u, merge: true)
                    } catch {
                        print("Error saving user: \(error)")
                    }
                }
                self.isSignedIn = true
            } else {
                print("Sign-out")
                self.isSignedIn = false
            }
        }
    }

    var email: String {
        guard let user = Auth.auth().currentUser else {
            return ""
        }

        return user.email ?? ""
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    deinit {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
