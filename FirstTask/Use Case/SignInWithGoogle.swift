import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit

class SignInWithGoogle {
    func call(presenting viewController: UIViewController, completion: @escaping @Sendable (Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(error)
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(nil)
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { _, error in
                completion(error)
            }
        }
    }
}
