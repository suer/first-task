import FirebaseAuth

class SessionState: ObservableObject {
    @Published var isSignedIn: Bool = false
    private var handle: AuthStateDidChangeListenerHandle!

    init() {
        handle = Auth.auth().addStateDidChangeListener { (_, user) in
            if user != nil {
                print("Sign-in")
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
