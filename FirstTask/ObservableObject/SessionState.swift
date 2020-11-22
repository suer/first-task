import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class SessionState: ObservableObject {
    @Published var isSignedIn: Bool = false
    private var handle: AuthStateDidChangeListenerHandle!

    init() {
        handle = Auth.auth().addStateDidChangeListener { (_, user) in
            if user != nil {
                print("Sign-in")
                if let user = user {
                    Firestore.firestore().collection("users")
                        .document(user.uid).setData([
                            "email": user.email ?? "",
                            "photoURL": user.photoURL?.absoluteString ?? ""
                        ])
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
