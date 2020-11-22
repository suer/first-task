import SwiftUI
import FirebaseUI

struct FirebaseUIView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let authUI = FUIAuth.defaultAuthUI()!
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        authUI.providers = providers

        return authUI.authViewController()
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
